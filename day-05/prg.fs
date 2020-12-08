20 constant width
66 constant B
82 constant R

: parseRow { str -- row }
  0 64 7 0 u+do ( acumulator power 7-0 )
    str i chars + c@
    B = if
      dup rot + swap
    endif
    2 /
  loop
  drop ;

: parseCol { str -- col }
  0 4 3 0 u+do ( acumulator power 3-0 )
    str i 7 + chars + c@
    R = if
      dup rot + swap
    endif
    2 /
  loop
  drop ;  

: parseSeat { str -- row col }
  str parseRow str parseCol ;

: seatId { row col -- id } 
  row 8 * col + ;

Create line-buffer width allot
0 Value fd-in

: passes { op }
  s" input" r/o open-file throw TO fd-in
  begin
    line-buffer width fd-in read-line throw
    drop dup 0>
  while
    drop line-buffer op execute
  repeat
  fd-in close-file throw
  drop ;

: print { pass }
  pass 10 type 10 emit ;

-1 Value maxPassId

: maxPass { pass }
  pass parseSeat seatId
  dup maxPassId > if
    TO maxPassId
  else
    drop
  endif ;

' maxPass passes
maxPassId .

create seats maxPassId 1 + cells allot
: clear
  maxPassId 1 + 0 u+do
    0 seats i cells + ! 
  loop ;
clear

: markPass { pass }
  pass parseSeat seatId
  dup seats swap cells + ! ;

' markPass passes

: findEmpty
  1 begin
    dup seats swap cells + @ 0=
    over seats swap 1 - cells + @ 0<>
    and invert
  while
    1+
  repeat ;

findEmpty .

bye
