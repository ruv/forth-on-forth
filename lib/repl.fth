\ 2020-02-23 ruv


variable a-reset-warm-handler
  :noname 0 0 a-lexeme-unresolved 2! postpone [ ;  a-reset-warm-handler !
: reset-warm ( -- ) a-reset-warm-handler @ execute ;
: add-reset-warm-handler ( xt -- )
  >r :noname
    a-reset-warm-handler @ compile,
    r> compile,
  postpone ; a-reset-warm-handler !
;

: show-prompt ( -- )
  cr
  ."  (" depth 0 u.r ." ) "
  s1 if
    ." C> "
  else
    ." #> "
  then
;
: show-error-source ( code -- )
  cr
  dup -13 = if a-lexeme-unresolved 2@ drop if
    ." \ Error, unresolved name: " a-lexeme-unresolved 2@ type cr
  then then
  ." \ Error #" dup . cr
  source nip if
    ." \ The parsed part: "
    source >in @ umin type cr
  then
  drop
;

: translate-input-interactive ( i*x -- j*x )
  begin translate-parse-area show-prompt refill 0= until
;
: translate-input-maybe-interactive ( i*x -- j*x )
  source-id if translate-input else translate-input-interactive then
;

: repl ( i*x -- j*x )
  source-id 0= if
    ." \ Info: Press Ctrl+D on Linux, or Ctrl+Z on Windows to break this REPL." cr
  then
  begin
    ['] translate-input-maybe-interactive catch dup 0= if drop exit then
    source nip dup 0= swap >in @ u< or >r
    dup show-error-source
      r> if ." \ Stop due to error on refill." cr throw then
      source-id if ." \ Stop due to non-zero source-id." cr throw then
    drop
    >in 1+! \ to avoid endless loop
    reset-warm
  again
;
