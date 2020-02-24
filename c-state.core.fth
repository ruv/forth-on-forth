\ 2020-02-20 22:20:53 -- W08 -- Thu

\ The compilation level state
variable a-c-state  a-c-state 0!

: inc-c ( -- )  1 a-c-state +! ;
: dec-c ( -- ) -1 a-c-state +! ;


\ "c1" returns true if the compilation level is 1, or false otherwise;
\ if the level > 1 it throws an exception (due to unsupported nesting at the moment).
: c1 ( -- flag ) a-c-state @ dup 1 = if 0<> exit then dup if a-c-state 0! -29 throw then ; \ -29 compiler nesting

\ Markup words
forth-wl-new exch-current
  : c{ inc-c ; immediate
  : }c dec-c ; immediate
exch-current drop


\ We need the "itself" word for shorter definitions.
\ So let's use a kind of Y-combinator if "itself" is not available.
[undefined] itself [if]
  \ The idea:
  \     : foo [: ( ... itself -- ... ) {: itself :}   itself . itself, ;] dup execute ;
  \   <==>
  \     : foo y{ itself . itself, }y ;
  \
  \   Where "itself," <==> "itself dup lit, compile,"
  \
  \   NB: "y{" shall be the first word in a definition (!)
  \       and locals are not allowed in such definitions.
  \
  [defined] (local) [if]
    : y{ postpone [: s" itself" (local) 0 0 (local) ; immediate
  [else] [defined] {: [if]
    : y{ postpone [: s" {: itself :}" evaluate ; immediate
  [else]
    : y{ postpone [: s" { itself }" evaluate ; immediate
  [then] [then]

    : }y postpone ;] postpone dup postpone execute ; immediate
    : itself, ( -- ) s" itself" evaluate postpone dup postpone lit, postpone compile, ; immediate

[else] \ Having native "itself", "y{" and "}y" do nothing
    : y{ ; immediate
    : }y ; immediate
    : itself, postpone itself postpone compile, ; immediate
[then]




\ Definition of the token compilers that respect c-state

\ "ct-" prefix stands for "compile token".
\ "ct-xt" compiles an xt (i.e., it appends the given execution semantics into the current definition);
\ "ct-lit" compiles a single number literal;
\ etc.

\ A common factor of almost all the token compilers
\   : -reproduce-or- ( RUN-TIME: x -- | x -- x ) c{ c1 if lit, itself, exit then }c ; immediate
: -reproduce-or-  postpone c1  postpone if  postpone lit,  postpone itself,  postpone exit  postpone then  ;  immediate

\ Compile xt token
: ct-xt   ( xt -- ) y{ -reproduce-or- compile, }y ;

\ Compile single number literal token
: ct-lit  ( x --  ) y{ -reproduce-or- lit, }y ;

\ Generalization of literals
: ct-lit-with ( i*x xt-lit -- ) y{ dup >r execute r> -reproduce-or- drop }y ;

\ Compilers for other literals
: ct-2lit ( x x -- )    ['] 2lit, ct-lit-with ;
: ct-slit ( addr u -- ) ['] slit, ct-lit-with ;


\ Perform or delay depending on c-state the compilation semantics that is represented by xt
: ct-compilation ( i*x xt-compilation -- j*x ) y{ -reproduce-or- execute }y ;



\ That's all.  Other words just should use ct-* basis for compilation (code generation).
