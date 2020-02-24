\ rvm 2012, 2018-08-16

\ The useful factors

\ Drop the flag; return control to the calling definition if the flag is not zero.
: ?E ( flag -- ) \ Exit on true
  postpone if postpone exit postpone then
; immediate

\ Return control to the calling definition if the top value is not zero.
: T?E ( x -- x )
  postpone dup postpone ?E
; immediate

\ Return control to the calling definition if the top value is zero.
: 0?E ( x -- x )
  postpone dup postpone 0= postpone ?E
; immediate

\ Return control to the calling definition if the top value is not zero,
\ otherwise drop the top value (that is zero).
: ?ET ( 0 -- | x -- x ) \ Exit on true returning this true
  postpone T?E postpone drop
; immediate

\ Return control to the calling definition if the top value is zero,
\ otherwise drop the top value (that is not zero).
: ?E0 ( x -- | 0 -- 0 ) \ Exit on 0 returning this 0
  postpone 0?E postpone drop
; immediate


\ If x1 and x2 are equal then drop them both and push true,
\ otherwise drop the top one and push false.
: =? ( x1 x2 -- x1 false | true )
  over = dup if nip then
;
