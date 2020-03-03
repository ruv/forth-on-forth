\ 2018-10-03
\ 2020-03-03 ruv

\ see also
\   https://github.com/ruv/forth-design-exp/blob/master/lexeme-translator/advanced.example.fth


2variable a-lexeme-unresolved

: ?nf ( i*x c-addr u 0 -- j*x -13 | k*x nonzero -- k*x )
  ?E a-lexeme-unresolved 2!
  -13 throw \ "undefined word" error
;
: ?stack ( -- ) depth 0 < -4 and throw ; \ stack underflow




: next-lexeme ( -- c-addr u|0 )
  begin parse-lexeme ?ET ( addr ) refill ?E0 drop again
;
: next-lexeme? ( -- c-addr u true | false )
  next-lexeme dup if true exit then nip
;
: translate-lexeme-sure ( i*x c-addr u -- j*x )
  translate-lexeme ?nf ?stack
;


\ : parse-area ( -- addr u ) source >in @ /string ;

: translate-parse-area ( i*x -- j*x )
  begin parse-lexeme dup while translate-lexeme-sure repeat 2drop
;
: translate-input ( i*x -- j*x )
  begin translate-parse-area refill 0= until
;
: translate-input-till ( i*x c-addr u -- j*x )
  2>r begin next-lexeme dup while
    2dup 2r@ equals 0= while
    translate-lexeme-sure
  repeat
    2drop rdrop rdrop exit
  then -22 throw \ control structure mismatch
;
