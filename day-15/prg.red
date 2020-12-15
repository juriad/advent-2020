Red [Title: "Prg"]

args: split system/script/args " "
file: make file! (replace/all (args/1) "'" "")
num: make integer! (replace/all (args/2) "'" "")

; print file
; print num

lines: read/lines file

foreach line lines [
    ; print line

    mem: append/dup make block! num -1 num
    i: 1
    foreach n (split line ",") [
        n: (make integer! n)
        poke mem (n + 1) i
        i: i + 1
    ]

    ; print mem
    ; print n

    while [ i <= num ] [
        ; print "===="
        ; print mem
        ; print n
        ; print "----"

        w: pick mem (n + 1)
        m: n

        ; print w

        either (w = -1) or (w = (i - 1)) [
            ; print "never"
            n: 0
        ] [
            ; print "before"
            n: i - w - 1
        ]
        ; print n

        poke mem (m + 1) (i - 1)
        i: i + 1
    ]

    print n
]
