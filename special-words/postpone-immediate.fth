\ 2019-09-24 ruv

\ see-also: https://git.io/JvctZ

variable state-dirty  \ private

: state-on  ( -- ) state-dirty on   ] ;
: state-off ( -- ) state-dirty on   postpone [ ; \  [ ' [ compile, ]

: execute-compiling ( i*x xt --j*x )
  state @ if  execute  exit  then
  state-dirty @ >r state-on state-dirty off  execute  state-dirty @ if rdrop exit then state-off r> state-dirty !
;
: execute-interpreting ( i*x xt --j*x )
  state @ 0= if  execute  exit  then
  state-dirty @ >r state-off state-dirty off  execute  state-dirty @ if rdrop exit then state-on r> state-dirty !
;

: postpone ( -- ) \ "name"
  ?state
  parse-lexeme resolve-word-stateful ?nf
  swap lit, if ['] execute-compiling else ['] compile, then compile,
; immediate

[defined] [compile] [if]
: [compile] ( -- ) \ "name"
  ?state
  parse-lexeme resolve-word-stateful ?nf
  \ Applying [compile] to an immediate word is dissallowed,
  \ since "[compile] exit" should be equivalent to just "exit",
  \ and it cannot be guranteed in this implementation.
  if -32 throw then \ "invalid name argument"
  compile,
; immediate
[then]



\ Redefenition of the words that change STATE to also set "state-dirty".
\
\ see: 6.1.2250 STATE, 15.6.2.2250 STATE
\   -- https://forth-standard.org/standard/core/STATE
\     Only the following standard words alter the value in STATE:
\     ":" (colon), ";" (semicolon), ABORT, QUIT, :NONAME, "[" (left-bracket), "]" (right-bracket).
\   -- https://forth-standard.org/standard/tools/STATE
\     allow ;CODE to change the value in STATE.

: [ state-off   ; immediate
: ] state-on    ;

: :noname   state-dirty on  :noname ;
: :         state-dirty on  : ;
: ;         state-dirty on  postpone ; ; immediate

: abort     state-dirty on  abort ;
: quit      state-dirty on  quit ;

[defined] ;code [if]
  : ;code state-dirty on postpone ;code ; immediate
[then]
