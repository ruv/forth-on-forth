\ 2020-02-20 22:20:53 -- W08 -- Thu


\ Create wrappers to the special standard words, for that a standard program is not allowed
\ to obtain execution token (and so these words may have special compilation semantics)

\ wordlist constant forth-wl-new \ the wordlist for the new Forth system words


\ The following well-known tool word is used here:
\   execute-parsing ( i*x c-addr u xt -- j*x )
\   see:
\     https://github.com/forthy42/gforth/blob/master/compat/execute-parsing.fs
\     https://theforth.net/package/compat/current-view/execute-parsing.fs
\   see also:
\     http://forth.sourceforge.net/word/evaluate-with/index.html

[undefined] execute-parsing [if] [defined] evaluate-with [if]
  : execute-parsing evaluate-with ; \ it's just a synonym
[then] [then]


: available ( c-addr u -- flag ) ['] [defined] execute-parsing ;
: unavailable ( c-addr u -- flag ) available 0= ;

\ The "quiet" mode
[undefined] quietness [undefined] execute-quiet or [if]
  variable a-quiet
  : quietness ( -- 0|x ) a-quiet @ ;
  : execute-quiet ( i*x xt -- j*x ) a-quiet dup @ >r on execute r> a-quiet ! ;
[then]


\ Append the compilation semantics for the given word (by its name)
: compilation-sem, ( c-addr u -- ) [: postpone postpone ;] execute-parsing ;

\ Append xt literal of the compilation semantics for the given word (by its name)
: compilation-lit, ( c-addr u -- )
  2>r  postpone [:  2r> compilation-sem,  postpone ;]
;

: start-def-named ( c-addr u -- ) ( C: -- colon-sys ) ['] : execute-parsing ;
: end-def ( -- ) ( C: colon-sys -- ) postpone ; ;


: ?state ( -- ) state @ 0= if -14 throw then ; \ -14 "interpreting a compile-only word"

: ?show-warning-missed-word ( addr u -- )
  quietness if 2drop exit then
  ." \ Info, a mentioned word isn't found: " type cr
;

: for-each-word-in-parse-area ( xt -- )
  \ xt ( addr u -- ) \ xt is applied to the available word only
  >r begin parse-lexeme dup while
    2dup unavailable if ?show-warning-missed-word else r@ execute then
  repeat 2drop rdrop
;
: for-each-def-in-parse-area ( xt -- )
  \ xt ( addr u -- ) \ xt is called to compile the body of the redefined word
  [: ( xt addr u -- xt )
    2dup depth >r start-def-named depth r> - ( execute-balance ) 2 + n>r
      postpone ?state
      rot dup >r execute r>
    nr> drop end-def immediate
  ;] for-each-word-in-parse-area drop
;


\ Examples of wrappers for non-parsing special words:
\   : if [: postpone if ;] et-xt ; immediate
\   : >r [: postpone >r ;] et-xt ; immediate
\
: special-words< ( "ccc" -- )
  [: ( addr u -- )
    compilation-lit, postpone et-xt
  ;] for-each-def-in-parse-area
;


\ The expressions with the special parsing words should be transformed as the following:
\   "X ccc"  ==> "[ [: X ccc ;] ct-xt ]"  (but it isn't supported by some systems yet)
\           <==> "[: X ccc ;] [ c1 if postpone ct-xt else postpone execute then ]"
\           <==> "[: X ccc ;] [ c1 if 'ct-xt else 'execute then compile, ]"
\           <==> "[: X ccc ;] [ c1 if ] ct-xt [ else ] execute [ then ]"
\           <==> "[ c1 if ] [: X ccc ;] ct-xt [ else ] X ccc [ then ]"
\   (assuming that "if" properly works in interpretation state)
\
\ So the wrapper for a special parsing word X can have the following form:
\   : X  c1 if  postpone [:  postpone X  postpone ;]  postpone ct-xt  exit then  postpone X  ;  immediate
\
: special-parsing-words< ( "ccc" -- )
  [: ( addr u -- )
    2>r postpone c1 postpone if
      [: postpone [: ;] compile,
      2r@ compilation-sem,
      [: postpone ;] postpone ct-xt ;] compile,
    postpone exit postpone then
    2r> compilation-sem,
  ;] for-each-def-in-parse-area
;


\ Some words are not supported in c{ }c yet,
\ let them throw an exception if they are used in this context.
\
: unsupported-special-words< ( "ccc" -- )
  [: ( addr u -- )
    [: c1 abort" \ Error, a non supported word in 'c{ }c'" ;] compile, compilation-sem,
  ;] ['] for-each-def-in-parse-area execute-quiet
;




\ Define the wrappers for some special words (in the "forth-wl-new" wordlist)
forth-wl-new exch-current
  special-words<  exit recurse  itself
  special-words<  >r r> r@ rdrop  2>r 2r> 2r@ 2rdrop  n>r nr>
  special-words<  ; does>  ;code
  special-words<  ahead if else then endif begin again until while repeat
  special-words<  do ?do loop +loop i j unloop leave
  special-words<  case of endof endcase
  special-words<  [: ;]
  \ NB: the interpretation semantics for these words (if any) are lost.
exch-current drop

\ Control-flow stack is another special case
forth-wl-new exch-current
  [defined] cs-roll [if]  : cs-roll ( u -- )    et-lit   ['] cs-roll et-xt  ;   [then]
  [defined] cs-pick [if]  : cs-pick ( u -- )    et-lit   ['] cs-pick et-xt  ;   [then]
  [defined] cs-drop [if]  : cs-drop (   -- )             ['] cs-drop et-xt  ;   [then]
exch-current drop

\ Some other words
forth-wl-new exch-current
  [defined] (local) [if]  : (local) ( a u -- )  et-slit  ['] (local) et-xt  ;   [then]
  \ NB: the "{:" or "{" word should be defined via this "(local)" to be allowed in "c{ }c"
  \ (a wrapper for "{:" is just longer than usual wrappers)
  unsupported-special-words<  locals|  {:  {
  \ NB: at the moment, the names of local variables are not supported in c{ }c
  \ and this case cannot be handled without re-implementing locals.
  \ So the locals will be just compiled incorrectly.
exch-current drop


\ Well known basic code-generating words
forth-wl-new exch-current
  \ Now they are just synonyms for the new ct-* words
  : compile, ( xt -- )  ct-xt   ;
  : xt,      ( xt -- )  ct-xt   ; \ a shorter synonym for "compile,"
  : lit,  ( x -- )      ct-lit  ;
  : 2lit, ( x x -- )    ct-2lit ;
  : slit, ( a u -- )    ct-slit ;
exch-current drop


\ Special standard code-generating words for literals
forth-wl-new dup >order exch-current
  \ Use the new basic words (!)
  : literal   lit,    ; immediate
  : sliteral  slit,   ; immediate
  : 2literal  2lit,   ; immediate
exch-current drop previous


\ The wrappers for the special parsing words
forth-wl-new exch-current
  special-parsing-words<  postpone [compile]
  special-parsing-words<  ['] [char]
  special-parsing-words<  ."  c"  abort"
exch-current drop




\ In this PoC, the "dual-semantics" standard words can be only re-implemented.
\ There is no a standard way to just wrap the original words
\ (as in the case of the control-flow words).

\ Since these words should use the new code-generating basic words.
\ But we have the following issues:
\ 1) POSTPONE is not applicable to them
\    (hence, no universal way to get the compilation semantics for them)
\ 2) no universal way to get the interpretation semantics for them.

\ NB: in a Forth system implementation, the initial implementation
\ of these words should automatically use the proper code-generating words.

\ These words are: S" S\" TO IS ACTION-OF
\ See them in ./special-words/
