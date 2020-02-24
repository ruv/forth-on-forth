
\ Some well known words

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
: parse-lexeme ( -- addr u ) bl parse ;
: parse-name ( -- addr u ) parse-lexeme ;
[then] [then] [then]
