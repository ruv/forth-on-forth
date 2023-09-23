\ 2019-09-24 ruv

\ see-also:
\   https://gist.github.com/ruv/fe2256dde1ca304f31ed925c8b998259
\     -- An implementation of POSPONE via FIND
\   https://github.com/ForthHub/discussion/discussions/103
\     -- About POSTPONE semantics in edge cases

: compilation  ( -- flag )  state @ 0<> ;
: enter-compilation  ( -- )           ] ;
: leave-compilation  ( -- )  postpone [ ;

: execute-compiling ( i*x xt --j*x )
  compilation     if  execute  exit  then
  enter-compilation  execute  leave-compilation
;
: execute-interpreting ( i*x xt --j*x )
  compilation 0=  if  execute  exit  then
  leave-compilation  execute  enter-compilation
;
