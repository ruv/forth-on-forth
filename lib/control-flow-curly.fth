\ A fancy curly control flow structures
\ 2021 ruv
\ This file is licensed under Apache License 2.0. https://www.apache.org/licenses/LICENSE-2.0

\ -- history
\ 2021-03-27 --- initial version
\ 2021-03-30 --- add "repeat" "if-break" and "unless-break"
\ 2021-04-02 --- add "_magic-for-end"
\ 2023-10-20 --- use "p( ... )" to postpone several words

\ After implementing this, something similar was found in Forth Dimensions,
\ see: "Curly Control Structure Set" in FD 13/6 and FD 14/1 (1992).
\   https://archive.org/details/Forth_Dimension_Volume_13_Number_6/page/n21/mode/2up
\   https://archive.org/details/Forth_Dimension_Volume_14_Number_1/page/n25/mode/2up

\ Another similar PoC https://git.io/JvGOu


here 255 or constant _magic-for-end

\ DataType: end-sys ⇒ ( xt x.magic )

: p( ( "ccc <rparen>" -- ) \ Apply "postpone" to each lexeme in the input stream until the lexeme ")" is encountered
  begin parse-name dup 0= if 2drop refill  0= -39 and throw  recurse exit then
    2dup s" )" compare while  nip 1+ negate >in @ + 0 max >in !  postpone postpone
  repeat 2drop
; immediate

: ?end-sys ( end-sys -- end-sys  |  any\end-sys -- never ) dup _magic-for-end <> -22 and throw ;

: end ( i*x end-sys -- j*x ) ?end-sys drop execute ;
: } ( i*x end-sys -- j*x ) end ; immediate

: end{ ( -- quotation-sys end-sys ) p( [: )  [: p( ;] _magic-for-end ) ;]  _magic-for-end ; immediate
: }end ( quotation-sys end-sys -- ) end ; immediate
\ "}end" Run-time: ( -- end-sys )


: if{       ( -- orig end-sys ) p( if )  end{ p( then ) } ; immediate
: unless{   ( -- orig end-sys ) p( 0= if{ ) ; immediate
: }unless   ( orig end-sys -- ) end ; immediate
: }if       ( orig end-sys -- ) end ; immediate

: choose{ ( -- end-sys ) end{ }end ; immediate
: }choose ( end-sys i*{ orig end-sys } -- ) end ; immediate
: when{   ( -- orig end-sys ) p( if )  end{ p( else )  end{ p( then ) end }end  }end  ; immediate
: when{}  ( -- orig end-sys ) p( 0= if )               end{ p( then ) end }end        ; immediate
: }when   ( orig1 end-sys1 -- orig2 end-sys2 ) end ; immediate
: otherwise{ ( -- end-sys ) end{ }end ; immediate
: }otherwise ( end-sys -- ) end       ; immediate
: of{     ( -- orig end-sys ) p( over = if drop )  end{ p( else ) end{ p( then ) end }end  }end  ; immediate
: }of     ( orig1 end-sys1 -- orig2 end-sys2 ) end ; immediate
: of{}    ( -- orig end-sys ) p( of{ }of ) ; immediate


: repeat{ ( -- dest 0 end-sys ) p( begin ) 0  end{ >r p( again ) r> 0 ?do p( then ) loop }end ; immediate
: }repeat ( u*orig dest u end-sys -- ) end ; immediate


\ private helpers: the enclosed code is performed under ( u end-sys )
: _u{    p( ?end-sys 2>r >r )  end{ p( r>    2r> ) } ; immediate
: _u+{   p( ?end-sys 2>r >r )  end{ p( r> 1+ 2r> ) } ; immediate

\ ( u1 end-sys1 -- orig u2 end-sys1 end-sys2 )
: if-break{  _u+{ p( if ) }  end{ _u{ p( else )  1 cs-roll } } ; immediate
\ ( dest u1 end-sys1 -- orig dest u2 end-sys1 )
: if-break{} _u+{ p( 0= if )  1 cs-roll } ; immediate
\ ( dest orig1 u2 end-sys1 end-sys2 -- orig2 dest u2 end-sys1 )
: }if-break end ; immediate

\ ( dest u1 end-sys1 -- dest orig u2 end-sys1 end-sys2 )
: unless-break{   _u+{  p( 0= if )  }  end{ _u{  p( else )  1 cs-roll } } ; immediate
\ ( dest u1 end-sys1 -- orig dest u2 end-sys1 )
: unless-break{}  _u+{  p( if )  1 cs-roll } ; immediate
\ ( dest orig1 u2 end-sys1 end-sys2 -- orig2 dest u2 end-sys1 )
: }unless-break end ; immediate


\ ( dest u end-sys -- dest u end-sys )
: unless-cont{}   _u{ 0 cs-pick p( until ) } ; immediate
: if-cont{}       p( 0= unless-cont{} ) ; immediate

\ ( dest1 u end-sys1 -- dest1 orig dest1 u end-sys1 end-sys2 )
: if-cont{        _u{ p( if ) 1 cs-pick }  end{ _u{ p( again then ) } } ; immediate
: unless-cont{    p( 0= if-cont{ ) ; immediate

\ ( dest1 orig dest1 u end-sys1 end-sys2 -- dest1 u end-sys1 )
: }if-cont        end ; immediate
: }unless-cont    end ; immediate
