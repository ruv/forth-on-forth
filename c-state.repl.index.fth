\ 2020-02-24 ruv

include ./lib/compat.fth


include ./c-state.fth

\ get-current
support-c-state >order definitions

include ./buildup/state-control.fth

include ./lib/control-flow.fth
include ./lib/string-match.fth
include ./lib/resolver/api.fth
include ./lib/resolver/number.fth
include ./lib/resolver/word-via-find.fth
include ./lib/translate.fth


forth-wl-new exch-current

  : evaluate ['] translate-parse-area execute-parsing ;

  \ support for nested c{ c{ ... }c }c
  : c{ ( i*x -- j*x )
    c1 if
      postpone [:  s" }c" translate-input-till  postpone ;]  postpone ct-xt
    else
      inc-c  s" }c" translate-input-till  dec-c
    then
  ; immediate

  : }c -22 throw ; immediate \ "control structure mismatch"

exch-current drop



include ./lib/repl.fth

:noname a-c-state 0! ; add-reset-warm-handler


: resolve-number-any ( c-addr u -- i*x tt | c-addr u 0 )
  resolve-dn-dot-prefixed   ?ET
  resolve-n-prefixed        ?ET

  [defined] resolve-fn-e            [if]
  resolve-fn-e              ?ET     [then]

  false
;

: resolve-lexeme-default ( c-addr u -- i*x tt | c-addr u 0 )
  resolve-word-stateful     ?ET
  resolve-number-any        ?ET
  false
;

' resolve-lexeme-default set-perceptor


forth-wl-new >order definitions

include ./special-words/dual-semantics.immediate.fth
include ./special-words/postpone-immediate.fth


cr
.( \ The environment for testing c-state is loaded. ) cr
.( \ Use the "repl" word to start the interpreter loop. ) cr
.( \ ORDER [the top at the right]: forth support-c-state forth-wl-new ) cr
cr
