\ 2019-09-24 ruv

\ see-also: https://git.io/JvctZ

variable state-dirty  \ private (!)

: state-on  ( -- ) state-dirty on   ] ;
: state-off ( -- ) state-dirty on   postpone [ ; \  [ ' [ compile, ]

: execute-compiling ( i*x xt --j*x )
  state @ if  execute  exit  then
  state-on state-dirty off  execute  state-dirty @ if exit then state-off
;
: execute-interpreting ( i*x xt --j*x )
  state @ 0= if  execute  exit  then
  state-off state-dirty off  execute  state-dirty @ if exit then state-on
;


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


: postpone ( -- ) \ "name"
  parse-lexeme resolve-word-stateful ?nf
  swap lit, if ['] execute-compiling else ['] compile, then compile,
; immediate

: [compile] ( -- ) \ "name"
  parse-lexeme resolve-word-stateful ?nf
  if lit, ['] execute-compiling then compile,
; immediate
