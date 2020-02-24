\ 2006, 2007, 2018-08, 2020-02
\ ruv

variable a-current-resolver \ current lexeme resolver

: set-resolver      ( xt -- ) a-current-resolver ! ;
: resolver          ( -- xt ) a-current-resolver @ ;


: resolve-lexeme ( c-addr u -- k*x xt-tt | c-addr u 0 )
  resolver dup if execute then
;
: translate-lexeme ( i*x c-addr u -- j*x true | c-addr u 0 )
  resolve-lexeme dup if execute true then
;
\ NB: "translate-token" is just "execute"
