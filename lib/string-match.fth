\ rvm 2007, 2009, 2018-08-16


\ Functions Based on Substring Matching
\
\ see also
\   - documentation (ru):
\       https://raw.githack.com/rufig/spf4-utf8/master/devel/~pinka/proposal/string-plain.xml
\   - documentation sources (ru)
\       https://github.com/rufig/spf4-utf8/blob/master/devel/~pinka/proposal/string-plain.xml


\ Naming convention was taken from the similar XPath functions.
\ String length is calculated in the address units.

\ Check compatibility wrt working with character units.
1 chars 1 <> [if]
  pad 1 chars 1 /string drop pad - 1 <> [if]
    .( Sorry, chars handling in this program is incompatible with the host Forth system. Abort. ) cr
    abort
  [then]
[then]


: match-char-head ( c-addr u c -- c-addr2 u2 true | c-addr u false )
  over 0= if drop false exit then
  >r over c@ r> = ?E0 1 chars /string true
;

: match-char-tail ( c-addr u c -- c-addr u2 true | c-addr u false )
  over 0= if drop false exit then
  >r 2dup + char- c@  r> = ?E0 char- true
;



: equals ( c-addr1 u1 c-addr2 u2 -- flag )
  dup 3 pick <> if 2drop 2drop false exit then
  compare 0=
;
: match-head ( a u a-key u-key -- a-right u-right true | a u false )
  2 pick over u< if  2drop false exit then
  dup >r
  3 pick r@ compare if  rdrop false exit then
  swap r@ + swap r> - true
;
: match-tail ( a u a-key u-key -- a-left u-left true | a u false )
  2 pick over u< if  2drop false exit then
  dup >r
  2over r@ - + r@ compare if  rdrop false exit then
  r> - true
;
: contains ( a u a-key u-key -- flag )
  search nip nip
;
: starts-with ( a u a-key u-key -- flag )
  rot over u< if  2drop drop false exit then
  tuck compare 0=
;
: ends-with ( a u a-key u-key -- flag )
  dup >r 2swap dup r@ u< if  2drop 2drop rdrop false exit then
  r@ - + r> compare 0=
;
: substring-after ( a u a-key u-key -- a2 u2 )
  dup >r search if  swap r@ + swap r> - exit then  rdrop 2drop 0 0
;
: substring-before ( a u a-key u-key -- a2 u2 )
  3 pick >r  search  if  drop r> tuck - exit then   rdrop 2drop 0 0
;



: split- ( a u a-key u-key -- a-right u-right a-left u-left true | a u false )
  3 pick >r dup >r      ( r: a u1 )
  search    if          ( aa uu )
  over r@ + swap r> -   ( aa aa+u1  uu-u1     ) \ the right part
  rot r@ - r> swap      ( aa+u1 uu-u1  a aa-a ) \ the left part
  true exit then
  2r> 2drop false
;

: split ( a u a-key u-key -- a-left u-left a-right u-right true | a u false )
  dup >r 3 pick >r      ( r: u1 a )
  search    if          ( aa uu )
  swap r@ over r> -     ( uu aa  a aa-a       ) \ the left part
  2swap r@ + swap r> -  ( a aa-a  aa+u1 uu-u1 ) \ the right part
  true exit then
  2r> 2drop false
;
