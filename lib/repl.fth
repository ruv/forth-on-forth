\ 2020-02-23 ruv

2variable a-lexeme-unresolved

: ?nf ( i*x c-addr u 0 -- j*x -13 | k*x true -- k*x )
  ?E a-lexeme-unresolved 2!
  -13 throw \ "undefined word" error
;
: ?stack ( -- ) depth 0 < -4 and throw ; \ stack underflow

\ : parse-area ( -- addr u ) source >in @ /string ;


: translate-parse-area ( i*x -- j*x )
  begin parse-lexeme dup while translate-lexeme ?nf ?stack repeat 2drop
;
: translate-input ( i*x -- j*x )
  begin translate-parse-area refill 0= until
;



: __reset-warm ( -- ) ; \ word for late binding

: show-prompt ( -- )
  source-id ?E
  cr
  ."  (" depth 0 u.r ." ) "
  s1 if
    ." C> "
  else
    ." #> "
  then
;
: show-error-source ( code -- )
  cr
  dup -13 = if
    ." \ Error, unresolved name: " a-lexeme-unresolved 2@ type cr
  then
  ." \ Error #" dup . cr
  source nip if
    ." \ The parsed part: "
    source >in @ umin type cr
  then
  drop
;

: translate-input-interactive ( i*x -- j*x )
  \ source-id if translate-input exit then
  \ begin translate-parse-area show-prompt refill 0= until
  begin show-prompt refill while translate-parse-area repeat
;

: repl ( i*x -- j*x )
  ." \ Info: Press Ctrl+D on Linux, or Ctrl+Z on Windows to break this REPL." cr
  begin
    ['] translate-input-interactive catch dup 0= if drop exit then
    source nip >r
    dup show-error-source
      r> 0= abort" \ Critical error, cannot read the input source. ABORT."
      source-id if ." \ Stop due to non-zero source-id." cr throw exit then
    drop
    postpone [ s" __reset-warm" evaluate
  again
;
