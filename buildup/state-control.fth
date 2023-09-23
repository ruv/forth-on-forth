\ 2019-09-24 ruv

\ see-also:
\   https://gist.github.com/ruv/fe2256dde1ca304f31ed925c8b998259
\     -- An implementation of POSPONE via FIND
\   https://github.com/ForthHub/discussion/discussions/103
\     -- About POSTPONE semantics in edge cases

: state-on  ( -- )  ] ;
: state-off ( -- )  postpone [ ; \  [ ' [ compile, ]

: execute-compiling ( i*x xt --j*x )
  state @ if  execute  exit  then
  state-on  execute  state-off
;
: execute-interpreting ( i*x xt --j*x )
  state @ 0= if  execute  exit  then
  state-off  execute  state-on
;
