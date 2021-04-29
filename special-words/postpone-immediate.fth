\ 2019-09-24 ruv

\ see-also: https://git.io/JvctZ


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

