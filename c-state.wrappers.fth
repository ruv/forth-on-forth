\ 2020-02-20 22:20:53 -- W08 -- Thu


\ Create wrappers to the special standard words, for that a standard program is not allowed
\ to obtain execution token (and so these words may have special compilation semantics)

\ wordlist constant forth-wl-new \ the wordlist for the new Forth system words


\ The following well-known tool word is used here:
\   execute-parsing ( i*x c-addr u xt -- j*x )
\   see:
\     https://github.com/forthy42/gforth/blob/master/compat/execute-parsing.fs
\     https://theforth.net/package/compat/current-view/execute-parsing.fs


: available ( c-addr u -- flag ) ['] [defined] execute-parsing ;
: unavailable ( c-addr u -- flag ) available 0= ;

\ Append the compilation semantics for the given word (by its name)
: compilation-sem, ( c-addr u -- ) [: postpone postpone ;] execute-parsing ;

\ Append xt literal of the compilation semantics for the given word (by its name)
: compilation-lit, ( c-addr u -- )
  2>r  postpone [:  2r> compilation-sem,  postpone ;]
;

: start-def-named ( c-addr u -- ) ['] : execute-parsing ;
: end-def ( c-addr u -- ) postpone ; ;


: show-warning ( addr u -- ) ." \ Info, a menioned word isn't found: " type cr ;

: for-each-word-in-parse-area ( xt -- )
  \ xt ( addr u -- ) \ xt is applied to the available word only
  >r begin parse-lexeme dup while
    2dup unavailable if show-warning else r@ execute then
  repeat 2drop rdrop
;


\ Examples of wrappers for non-parsing special words:
\   : if [: postpone if ;] ct-compilation ; immediate
\   : do [: postpone do ;] ct-compilation ; immediate
\   : >r [: postpone >r ;] ct-compilation ; immediate
\
: special-words< ( "ccc" -- ) [:
    2dup 2>r start-def-named
      2r> compilation-lit, postpone ct-compilation
    end-def immediate
  ;] for-each-word-in-parse-area
;


\ The expressions with the special parsing words should be transformed as the following:
\   "X ccc"  ==> "[ [: X ccc ;] ct-compilation ]"  (not supported yet by some systems)
\           <==> "[: X ccc ;] [ c1 if postpone ct-xt else postpone execute then ]"
\ So a wrapper for the special parsing word X have the following form:
\   : X  postpone [:  postpone X  postpone ;]  c1 if postpone ct-xt else postpone execute then ;  immediate
\
: special-parsing-words< ( "ccc" -- ) [:
    2dup 2>r start-def-named
      [: postpone [: ;] compile,
      2r> compilation-sem,
      [: postpone ;] ;] compile,
      [: c1 if postpone ct-xt else postpone execute then ;] compile,
    end-def immediate
  ;] for-each-word-in-parse-area
;




\ Define the wrappers for some special words (in the "forth-wl-new" wordlist)
forth-wl-new exch-current
  special-words<  exit recurse
  special-words<  >r r> r@ 2>r 2r> 2r@  n>r nr>
  special-words<  ; does>
  special-words<  ahead if else then endif begin again until while repeat
  special-words<  do ?do loop +loop i j unloop leave
  special-words<  case of endof endcase
exch-current drop

\ Control-flow stack is another special case
forth-wl-new exch-current
  [defined] cs-roll [if]  : cs-roll ( u -- ) y{ -reproduce-or- cs-roll }y ;           [then]
  [defined] cs-pick [if]  : cs-pick ( u -- ) y{ -reproduce-or- cs-pick }y ;           [then]
  [defined] cs-drop [if]  : cs-drop (   -- ) y{ c1 if itself, exit then cs-drop }y ;  [then]
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
forth-wl-new exch-current
  : literal   lit,    ; immediate
  : sliteral  slit,   ; immediate
  : 2literal  2lit,   ; immediate
exch-current drop


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
\ NB: in a Forth system implementation, the initial implementation
\ of these words should automatically use the proper code-generating words.

\ These words are: S" S\" TO IS ACTION-OF
\ See them in ./special-words/
