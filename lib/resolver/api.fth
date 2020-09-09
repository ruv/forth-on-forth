\ 2006, 2007, 2018-08, 2020-02
\ ruv

variable a-perceptor \ slot for a lexeme resolver that is currently used by the system

: set-perceptor     ( xt -- ) a-perceptor ! ;
: perceptor         ( -- xt ) a-perceptor @ ;

: perceive ( c-addr u -- k*x xt-tt | c-addr u 0 )
  perceptor execute
;

\ translate fully qualified token
: translate-qtoken ( i*x k*x xt-tt -- j*x true | k*x 0 -- k*x 0 )
  dup if execute true then
;
\ translate a lexeme in the current dynamic context
: translate-lexeme ( i*x c-addr u -- j*x true | c-addr u 0 )
  perceive translate-qtoken
;
