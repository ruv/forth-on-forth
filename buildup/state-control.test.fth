
: s ( -- flag-compiling ) compilation 0<> ;
: t ( i*x xt -- j*x flag-compiling ) execute s leave-compilation ;

T{ ' s ' execute-compiling ' execute-interpreting  ' execute-compiling t -> -1 0 }T

T{ :noname s enter-compilation ; ' execute-compiling ' execute-interpreting  ' execute-compiling t -> -1 0 }T

T{ :noname s enter-compilation  ['] s execute-interpreting ;  ' execute-compiling t -> -1 0 0 }T
