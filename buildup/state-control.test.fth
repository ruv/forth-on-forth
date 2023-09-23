
: s ( -- flag-compiling ) state @ 0<> ;
: t ( i*x xt -- j*x flag-compiling ) execute s state-off ;

T{ ' s ' execute-compiling ' execute-interpreting  ' execute-compiling t -> -1 0 }T

T{ :noname s state-on ; ' execute-compiling ' execute-interpreting  ' execute-compiling t -> -1 0 }T

T{ :noname s state-on  ['] s execute-interpreting ;  ' execute-compiling t -> -1 0 0 }T
