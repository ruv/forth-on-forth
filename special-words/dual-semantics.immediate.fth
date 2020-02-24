\ 2019-09-24 ruv

\ Implementation of the special "dual semantics" words
\ as STATE-dependent immediate words.

\ The following words are implemented here:
\   S" TO IS ACTION-OF
\ and the corresponding words for them:
\   VALUE DEFER DEFER@ DEFER!
\ NB: this "TO" cannot be applied to the local variables

\ NB: 2VALUE and FVALUE can be easy implemeted too,
\ with a bit modification of TO and VALUE

\ see-also: https://git.io/JvctZ


\ An initial action for a deferred word
: error-np ( -- ) -21 throw ; \ Not Provided, "unsupported operation"


\ Implementing of: 'to', 'is', 'action-of', 's"'
: value create , does> @ ;
: defer create ['] error-np , does> @ execute ;
: defer@ >body @ ;
: defer! >body ! ;
: is ' >body tt-lit ['] ! tt-xt ; immediate
: to [ ' is compile, ] ; immediate \ synonym; don't use postpone
: action-of ' >body tt-lit ['] @ tt-xt ; immediate
: s" [char] " parse tt-slit ; immediate
