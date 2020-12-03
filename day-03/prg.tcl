proc loadGrid {filename} {
    set f [open $filename]
    set data [read $f]
    set rows [split [string trim $data] "\n"]

    set grid [list]
    foreach row $rows {
        lappend grid [split $row ""]
    }

    close $f
    return $grid
}

proc get {grid x y} {
    set row [lindex $grid $y]
    set width [llength $row]
    return [lindex $row [expr {$x % $width}]]
}

proc countHits {grid dy dx} {
    set height [llength $grid]
    set x 0
    set y 0
    set cnt 0

    while {$y < $height} {
        set c [get $grid $x $y]
        # puts "$y $x $c"
        if {$c == "#"} {
            incr cnt
        }

        set y [expr {$y + $dy}]
        set x [expr {$x + $dx}]
    }
    return $cnt
}



set grid [loadGrid [lindex $argv 0]]
# puts $grid

set d1r1 [countHits $grid 1 1]
set d1r3 [countHits $grid 1 3]
puts $d1r3
set d1r5 [countHits $grid 1 5]
set d1r7 [countHits $grid 1 7]
set d2r1 [countHits $grid 2 1]

set mul [expr {$d1r1 * $d1r3 * $d1r5 * $d1r7 * $d2r1}]
puts $mul
