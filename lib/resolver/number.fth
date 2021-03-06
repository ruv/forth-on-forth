\ 2006, 2007, 2018-08, 2020-02
\ ruv

\ See also
\   https://github.com/ruv/forth-design-exp/blob/master/lexeme-translator/resolver.stdlib.fth


: resolve-dun ( c-addr u -- x x tt | c-addr u 0 )
  \ the lexeme is a double unsigned number (double-cell sized)
  dup ?E0 \ empty string is not a number
  2dup 0 0 2swap >number nip if 2drop 0 exit then 2nip ['] tt-2lit
;
: resolve-dn ( c-addr u -- x x tt | c-addr u 0 )
  \ the lexeme is a double number (with a possible leading minus sign)
  [char] - match-char-head >r
  resolve-dun dup if r> if >r dnegate r> then exit then
  drop r> if -1 chars /string then  0
;
: resolve-dn-dot ( c-addr u -- x x tt | c-addr u 0 )
  \ the lexeme is a double number with a trailing dot
  [char] . match-char-tail ?E0 resolve-dn ?ET char+ 0
;
: resolve-un ( c-addr u -- x tt | c-addr u 0 )
  \ the lexeme is an unsigned number (single-cell sized)
  resolve-dun dup if 2drop ['] tt-lit then
;
: resolve-n ( c-addr u -- x tt | c-addr u 0 )
  \ the lexeme is a number (single-cell sized, with a possible leading minus sign)
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
: resolve-n-prefixed ( c-addr u -- x tt | c-addr u 0 )
  \ the lexeme is a number with a possible prefix (single-cell sized)
  2dup extract-radix ?dup 0= if 2drop resolve-n exit then
  ['] resolve-n execute-with-base dup if 2nip exit then nip nip
;
: resolve-dn-prefixed ( c-addr u -- x x tt | c-addr u 0 )
  \ the lexeme is a double number with a possible prefix
  2dup extract-radix ?dup 0= if 2drop resolve-dn exit then
  ['] resolve-dn execute-with-base dup if >r 2nip r> exit then nip nip
;
: resolve-dn-dot-prefixed ( c-addr u -- x x tt | c-addr u 0 )
  \ the lexeme is a double number with a possible prefix and a trailing dot
  [char] . match-char-tail ?E0 resolve-dn-prefixed ?ET char+ 0
;
