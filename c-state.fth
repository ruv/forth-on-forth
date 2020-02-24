\ 2020-02-20 22:20:53 -- W08 -- Thu


\ NB: All the details are in  "support-c-state" and "forth-wl-new" word lists



\ Well known factors

[undefined] lit,    [if]  : lit,    postpone literal  ;   [then]
[undefined] 2lit,   [if]  : 2lit,   postpone 2literal ;   [then]
[undefined] slit,   [if]  : slit,   postpone sliteral ;   [then]

\ Avoid confusing a lexeme with a name token "nt" denoted  as "name" in the names of words
[undefined] parse-lexeme [if] : parse-lexeme parse-name ; [then]

: exch-current ( wid1 -- wid2 ) get-current swap set-current ;


\ The implmentation details are placed into the separate wordlist "c-state-support"
wordlist dup constant support-c-state dup >order exch-current

wordlist constant forth-wl-new \ the wordlist for the new Forth system words

forth-wl-new exch-current
  : support-c-state support-c-state ;
exch-current drop


include ./c-state.core.fth
include ./c-state.wrappers.fth


\ buffer for string literal
255 dup constant size-buf-slit cell+ allocate throw constant buf-slit
: carbon-slit ( a1 u -- a2 u ) dup size-buf-slit u> -19 and throw >r buf-slit tuck r@ move r> 2dup + 0! ;

: s1 ( -- flag ) state @ 0<> ;

\ Token translators that use token compilers
: tt-xt ( i*x xt -- j*x )     s1 if ct-xt       exit  then execute  ;
: tt-lit ( x -- | x )         s1 if ct-lit            then ;
: tt-2lit ( x x -- | x x )    s1 if ct-2lit           then ;
: tt-slit ( a1 u -- | a2 u )  s1 if ct-slit     exit  then carbon-slit ;
: tt-word ( i*x xt imm-flag -- j*x )
  s1 if if execute exit then ct-xt exit then drop execute
;



previous exch-current drop
