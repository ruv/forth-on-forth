\ 2006, 2007, 2018-08, 2020-02
\ ruv

\ See also
\   https://github.com/ruv/forth-design-exp/blob/master/lexeme-translator/resolver.stdlib.fth


: resolve-dun ( c-addr u -- x x tt | c-addr u 0 )
  dup ?E0 \ empty string is not a number
  2dup 0 0 2swap >number nip if 2drop 0 exit then 2nip ['] tt-2lit
;
: resolve-dn ( c-addr u -- x x tt | c-addr u 0 )
  [char] - match-head-char >r
  resolve-dun dup if r> if >r dnegate r> then exit then
  drop r> if -1 chars /string then  0
;
: resolve-dn-dot ( c-addr u -- x x tt | c-addr u 0 )
  [char] . match-tail-char ?E0 resolve-dn ?ET char+ 0
;
: resolve-un ( c-addr u -- x tt | c-addr u 0 )
  resolve-dun dup if 2drop ['] tt-lit then
;
: resolve-n ( c-addr u -- x tt | c-addr u 0 )
  resolve-dn dup if 2drop ['] tt-lit then
;
: extract-radix ( c-addr u -- c-addr u 0 | c-addr2 u2 radix )
  dup 1 u> ?E0  over c@
  [char] $ =? if 16 else
  [char] # =? if 10 else
  [char] % =? if 2  else
    drop s" 0x" match-head 16 and exit
  then then then >r 1 chars /string r>
;
: execute-with-base ( i*x base xt -- j*x )
  base @ >r swap base ! execute r> base !
;
: resolve-n-radix ( c-addr u -- x tt | c-addr u 0 )
  2dup extract-radix ?dup 0= if 2drop resolve-n exit then
  ['] resolve-n execute-with-base dup if 2nip exit then nip nip
;
: resolve-dn-radix ( c-addr u -- x x tt | c-addr u 0 )
  2dup extract-radix ?dup 0= if 2drop resolve-dn exit then
  ['] resolve-dn execute-with-base dup if >r 2nip r> exit then nip nip
;
: resolve-dn-dot-radix ( c-addr u -- x tt | c-addr u 0 )
  [char] . match-tail-char ?e0 resolve-dn-radix ?et char+ 0
;
