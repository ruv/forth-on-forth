
\ A funcy curly control flow structures
\ ruv

\ my another similar PoC https://git.io/JvGOu

\ 2021-03-27 --- initial version
\ 2021-03-30 --- add "repeat" "if-break" and "unless-break"
\ 2021-04-02 --- add "_magic-for-end"

\ After implementing this, something similar was found in Forth Dimensions,
\ see: "Curly Control Structure Set" in FD 13/6 and FD 14/1 (1992).
\   https://archive.org/details/Forth_Dimension_Volume_13_Number_6/page/n21/mode/2up
\   https://archive.org/details/Forth_Dimension_Volume_14_Number_1/page/n25/mode/2up


here 255 or constant _magic-for-end

\ end-sys ( xt magic )

: end ( i*x end-sys -- j*x ) _magic-for-end <> -22 and throw  execute ;
: } ( i*x end-sys -- j*x ) end ; immediate

: end{ postpone [:  [: postpone ;] postpone _magic-for-end ;] _magic-for-end ; immediate
: }end end ; immediate


: if{ postpone if  end{ postpone then } ; immediate
: unless{ postpone 0= postpone if{  ; immediate
: }unless end ; immediate
: }if end ; immediate

: choose{ end{ }end ; immediate
: }choose end ; immediate
: when{ ( xt -- orig u1 xt xt2 ) postpone if end{ postpone else end{ postpone then end } } ; immediate
: when{} ( u1 xt -- orig u2 xt ) postpone 0= postpone if end{ postpone then end } ; immediate
: }when end ; immediate
: otherwise{ end{ }end ; immediate
: of{ ( xt -- orig u1 xt xt2 ) postpone over postpone = postpone if postpone drop end{ postpone else end{ postpone then end } } ; immediate
: }of end ; immediate
: of{} ( u1 xt -- orig u2 xt ) postpone of{ postpone }of ; immediate


: repeat{ postpone begin  0 end{ >r postpone again r> 0 ?do postpone then loop } ; immediate
: }repeat end ; immediate

\ ( u1 end-sys1 -- u2 end-sys1 end-sys2 )
: if-break{ 2>r >r postpone if r> 1+ 2r> end{ 2>r >r postpone else 1 cs-roll r> 2r> } ; immediate
: if-break{} 2>r >r postpone 0= postpone if 1 cs-roll r> 1+ 2r> ; immediate
: }if-break end ; immediate

: unless-break{ 2>r >r postpone 0= postpone if r> 1+ 2r> end{ 2>r >r postpone else 1 cs-roll r> 2r> } ; immediate
: unless-break{} 2>r >r postpone if 1 cs-roll r> 1+ 2r> ; immediate
: }unless-break end ; immediate
