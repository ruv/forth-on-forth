
\ 2021-03-27 --- initial version
\ 2021-03-30 --- more test cases
\ 2021-04-02 --- extraction into separate file

\ if unless
T{ [: 2 0 do i if{ 1 } 9 loop ;] execute -> 9 1 9 }T
T{ [: 2 0 do i unless{ 0 } 9 loop ;] execute -> 0 9 9 }T

\ choose{ when{ } }
T{ [: 5 0 do i choose{ 1 =? when{ 1 } 2 =? when{ 2 } 3 =? when{} 4 =? when{ 4 } 5 }choose loop ;] execute -> 0 5 1 2 4 }T
T{ [: choose{ 1 0 when{  } 2 0 when{  } 3 0 when{} 4 0 when{ } 5 }choose ;] execute -> 1 2 3 4 5 }T

\ choose{ of{ } }
T{ [: 5 0 do i choose{ 1 of{ 1 } 2 of{ 2 } 3 of{} 4 of{ 4 } otherwise{ drop 5 } }choose loop ;] execute -> 5 1 2 4 }T

\ repeat{ if-break{ } unless-break{ } }
T{ [: 3 repeat{ dup 0= if-break{ 9 } dup 1- } ;] execute -> 3 2 1 0 9 }T
T{ : t2 repeat{ 1 =? if-break{ 1 } dup 2 = if-break{} dup 3 <> unless-break{ 0 } dup 4 <> unless-break{} 9 exit } ; -> }T
T{ [: 6 1 do i t2 loop ;] execute -> 1 2 3 0 4 5 9 }T

\ repeat{ if-cont{ } unless-cont{ } }repeat
t{ [: 3 repeat{ dup 0< if-break{} 1- dup 1 < if-cont{ 1 swap }  dup 2 < if-cont{ 2 swap }  3 swap } ;] execute -> 3 2 1 1 -1 }t

\ repeat{ if-cont{} unless-cont{} }repeat
t{ [: 3 repeat{ dup 0< if-break{} 1- dup 1 < if-cont{} 1 swap dup 2 < unless-cont{} 2 swap } ;] execute -> 1 1 2 -1 }t


: tch ( n1 -- n2 ) \ test choose
  choose{
    dup -5 < when{} \ just skip other cases
    dup 0<  when{ drop  10  }
    0       of{         20  }
    1       of{         30  }
    9 <     when{       40  }
                        50
    otherwise{          60  }
                        70
  }choose
;

t{ -7 tch -> -7 }t
t{ -2 tch -> 10 }t
t{  0 tch -> 20 }t
t{  1 tch -> 30 }t
t{  2 tch -> 40 }t
t{  8 tch -> 40 }t
t{  9 tch -> 50 60 70 }t
t{ 10 tch -> 50 60 70 }t
