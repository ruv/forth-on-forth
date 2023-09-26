
\ Some well known words

[undefined] on [if]
: on ( addr -- ) true swap ! ;
[then]

[undefined] off [if]
: off ( addr -- ) false swap ! ;
[then]

[undefined] 0! [if]
: 0! ( addr -- ) 0 swap ! ;
[then]

[undefined] 1+! [if]
: 1+! ( addr -- ) dup @ 1+ swap ! ;
[then]

[undefined] 1-! [if]
: 1-! ( addr -- ) dup @ 1- swap ! ;
[then]

[undefined] char- [if]
: char- ( addr1 -- addr2 ) -1 chars + ;
[then]

[undefined] 2nip [if]
: 2nip ( d2 d1 -- d1 ) 2swap 2drop ;
[then]

[undefined] rdrop [if]
: rdrop ( R: x -- ) postpone r> postpone drop ; immediate
[then]



[undefined] parse-lexeme [if]
[defined] parse-name [if]
: parse-lexeme parse-name ;
[else] [defined] parse-word [if]
: parse-lexeme parse-word ;
: parse-name parse-word ;
[else]
: parse-lexeme ( -- addr u ) \ via "word"
  bl word c@ dup 0= if source chars + swap exit then ( u )
  source drop >in @ 1- chars +  2dup  ( u addr2 u addr2 )
  c@ bl u> 0= abs  1- + ( u addr2 u2 )
  chars - swap
;
: parse-name ( -- addr u ) parse-lexeme ;
[then] [then] [then]



[undefined] >order [if]
: >order ( wid -- )
  >r get-order r> swap 1+ set-order
;
[then]
