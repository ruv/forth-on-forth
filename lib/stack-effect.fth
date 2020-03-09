\ 2007-2008

\ Take xt, execute it and push the stask depth difference
: execute-balance ( i*x xt -- j*x n )
  depth 1- >r execute depth r> -
;

\ Take n and xt, execute xt, throw exception
\ if the stack depth difference is not equal to n
: execute-balanced ( i*x xt n -- j*x ) \ j = i + n
  >r execute-balance r> = ?E -11 throw \ result out of range
;

\ Take xt and execute it, throw exception
\ if the stack depth difference is not equal to +1
: execute-balanced(+1) ( i*x xt -- i*x x )
  1 execute-balanced
;

\ See also: "execute-effect" word in Factor
\ https://docs.factorcode.org/content/word-execute-effect,combinators.html
