\ 2020-02-24 ruv

include ./lib/compat.fth


include ./c-state.fth

\ get-current
support-c-state >order definitions


include ./lib/control-flow.fth
include ./lib/string-match.fth
include ./lib/resolver/api.fth
include ./lib/resolver/number.fth
include ./lib/resolver/word-via-find.fth

include ./lib/repl.fth

:noname a-c-state 0! ; add-reset-warm-handler


forth-wl-new exch-current
  : evaluate ['] translate-parse-area execute-parsing ;
exch-current drop


: resolve-number-any ( c-addr u -- i*x tt | c-addr u 0 )
  resolve-dn-dot-radix      ?ET
  resolve-n-radix           ?ET

  [defined] resolve-fn-e            [if]
  resolve-fn-e              ?ET     [then]

  false
;

: resolve-lexeme-default ( c-addr u -- i*x tt | c-addr u 0 )
  resolve-word-stateful     ?ET
  resolve-number-any        ?ET
  false
;

' resolve-lexeme-default set-resolver


forth-wl-new >order definitions

include ./special-words/dual-semantics.immediate.fth
include ./special-words/postpone-immediate.fth


cr
.( \ The environment for testing c-state is loaded. ) cr
.( \ Use the "repl" word to start the interpreter loop. ) cr
.( \ ORDER [the top at the right]: forth support-c-state forth-wl-new ) cr
cr
