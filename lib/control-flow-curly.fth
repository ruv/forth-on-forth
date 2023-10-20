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

\ The data type "end-sys" is ( xt x.magic )

: p( ( "ccc<rparen>" -- ) \ Apply "postpone" to each word in the input stream until reach ")"
  begin parse-name dup 0= if 2drop refill 0= abort" (error, unexpected end of stream)" recurse exit then
    2dup s" )" compare while  nip 1+ negate >in @ + 0 max >in !  postpone postpone
  repeat 2drop
; immediate

: end ( i*x end-sys -- j*x ) _magic-for-end <> -22 and throw  execute ;
: } ( i*x end-sys -- j*x ) end ; immediate

: end{  p( [: )  [: p( ;] _magic-for-end ) ;]  _magic-for-end ; immediate
: }end end ; immediate


: if{       p( if )  end{ p( then ) } ; immediate
: unless{   p( 0= if{ ) ; immediate
: }unless end ; immediate
: }if end ; immediate

: choose{ end{ }end ; immediate
: }choose end ; immediate
: when{   ( -- orig end-sys ) p( if )  end{ p( else )  end{ p( then ) end }end  }end  ; immediate
: when{}  ( -- orig end-sys ) p( 0= if )               end{ p( then ) end }end        ; immediate
: }when end ; immediate
: otherwise{ end{ }end ; immediate
: of{     ( -- orig end-sys ) p( over = if drop )  end{ p( else ) end{ p( then ) end }end  }end  ; immediate
: }of end ; immediate
: of{}    ( -- orig end-sys ) p( of{ }of ) ; immediate


: repeat{ p( begin ) 0  end{ >r p( again ) r> 0 ?do p( then ) loop }end ; immediate
: }repeat end ; immediate

\ ( u1 end-sys1 -- orig u2 end-sys1 end-sys2 )
: if-break{   2>r >r  p( if )  r> 1+ 2r>  end{ 2>r >r  p( else )  1 cs-roll r> 2r> } ; immediate
: if-break{}  2>r >r  p( 0= if )  1 cs-roll r> 1+ 2r> ; immediate
: }if-break end ; immediate

: unless-break{   2>r >r  p( 0= if )  r> 1+ 2r>  end{ 2>r >r  p( else )  1 cs-roll r> 2r> } ; immediate
: unless-break{}  2>r >r  p( if )  1 cs-roll r> 1+ 2r> ; immediate
: }unless-break end ; immediate
