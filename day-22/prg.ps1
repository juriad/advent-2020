class CircularBuffer: System.Collections.IEnumerable
{
    [int]$head
    [int]$tail
    [int]$size
    [int]$capacity
    [int[]]$values

    CircularBuffer([int]$cap)
    {
        $this.head = 0
        $this.tail = 0
        $this.size = 0
        $this.capacity = $cap
        $this.values = [int[]]::new($cap)
    }

    [void]
    push([int]$val)
    {
        $this.values[$this.tail] = $val
        $this.tail = ($this.tail + 1) % $this.capacity
        $this.size++
    }

    [int]
    pop()
    {
        $val = $this.values[$this.head]
        $this.head = ($this.head + 1) % $this.capacity
        $this.size--
        return $val
    }

    [CircularBuffer]
    dup([int]$count)
    {
        $new = [CircularBuffer]::new($this.capacity)
        $i = 0;
        foreach ($val in $this)
        {
            $new.push($val)
            $i++
            if ($i -ge $count)
            {
                break
            }
        }
        return $new
    }

    [int]
    score()
    {
        $s = 0
        $n = $this.size
        foreach ($val in $this)
        {
            $s += $val * $n
            $n--
        }
        return $s
    }

    [int]
    hash()
    {
        $h = 0
        for ($i = 0; $i -lt $this.size; $i++) {
            $val = $this.values[($i + $this.head) % $this.capacity]
            $h = (($h -shl 7) -bxor $val) -band ((1 -shl 25) - 1)

            #$h = ($h * 253 + $val) % 15813257
        }
        return $h
    }

    [System.Collections.IEnumerator]
    GetEnumerator()
    {
        return [CircularBufferEnumerator]::new($this)
    }
}

class CircularBufferEnumerator: System.Collections.IEnumerator
{
    [CircularBuffer] $buffer
    [int] $index

    CircularBufferEnumerator([CircularBuffer] $buf)
    {
        $this.buffer = $buf
        $this.Reset();
    }

    [object]
    get_Current()
    {
        $ptr = ($this.buffer.head + $this.index) % $this.buffer.capacity
        return $this.buffer.values[$ptr]
    }

    [bool]
    MoveNext()
    {
        $this.index++
        return $this.index -lt $this.buffer.size
    }

    [void]
    Reset()
    {
        $this.index = -1;
    }
}

class Game
{
    [CircularBuffer] $p1
    [CircularBuffer] $p2
    [int] $depth

    Game([CircularBuffer] $p1, [CircularBuffer] $p2, [int] $depth)
    {
        $this.p1 = $p1
        $this.p2 = $p2
        $this.depth = $depth
    }

    [bool]
    play()
    {
        $d = $this.depth
        if ($d -ge 0)
        {
            $dd = "`t" * $d
        }
        else
        {
            $dd = ""
        }

        $p1s = $this.p1.size
        $p2s = $this.p2.size
        #        Write-Information -MessageData "$dd : Start : $p1s - $p2s" -InformationAction Continue

        $H = 256 * 256 * 8
        $hs = [int[]]::new($H)

        while ($this.p1.size -gt 0 -and $this.p2.size -gt 0)
        {
            if ($this.depth -ge 0)
            {
                $hh = $this.p1.hash() * 17 + $this.p2.hash()
                if ($hs[$hh % $H] -eq $hh)
                {
                    #                    Write-Information -MessageData "$dd : Cycle" -InformationAction Continue
                    return $true
                }
                else
                {
                    if ($hs[$hh % $H] -ne 0)
                    {
                        #                        Write-Information -MessageData "$dd : Conflict" -InformationAction Continue
                    }
                    $hs[$hh % $H] = $hh
                }
            }

            $c1 = $this.p1.pop()
            $c2 = $this.p2.pop()

            if ($this.depth -ge 0)
            {
                if ($this.p1.size -ge $c1 -and $this.p2.size -ge $c2)
                {
                    $pp1 = $this.p1.dup($c1)
                    $pp2 = $this.p2.dup($c2)

                    $g = [Game]::new($pp1, $pp2, $d + 1)
                    $firstWon = $g.play()
                }
                else
                {
                    $firstWon = $c1 -gt $c2
                }
            }
            else
            {
                $firstWon = $c1 -gt $c2
            }

            if ($firstWon)
            {
                #                Write-Information -MessageData "$dd : $c1 > $c2" -InformationAction Continue
                $this.p1.push($c1)
                $this.p1.push($c2)
            }
            else
            {
                #                Write-Information -MessageData "$dd : $c1 < $c2" -InformationAction Continue
                $this.p2.push($c2)
                $this.p2.push($c1)
            }
        }

        $firstWon = $this.p1.size -gt 0
        #        Write-Information -MessageData "$dd : $firstWon" -InformationAction Continue
        return $firstWon
    }
}

function load([string]$file)
{
    $cards = 0
    foreach ($line in Get-Content $file)
    {
        if ($line -match "^[0-9]+")
        {
            $cards++
        }
    }

    $p1 = [CircularBuffer]::new($cards)
    $p2 = [CircularBuffer]::new($cards)

    foreach ($line in Get-Content $file)
    {
        if ($line -match "^[0-9]+")
        {
            $p1.push([int]$line)
        }
        elseif ($line -match "^Player")
        {
            $p2, $p1 = $p1, $p2
        }
    }

    return $p2, $p1
}

function play([CircularBuffer] $p1, [CircularBuffer] $p2, [bool] $recursive)
{
    $pp1 = $p1.dup($p1.size)
    $pp2 = $p2.dup($p2.size)
    if ($recursive)
    {
        $g = [Game]::new($pp1, $pp2, 0)
    }
    else
    {
        $g = [Game]::new($pp1, $pp2, -1)
    }
    [void] $g.play()

    if ($pp1.size -lt $pp2.size)
    {
        $pp2, $pp1 = $pp1, $pp2
    }
    $s = $pp1.score()
    echo $s
}

$p1, $p2 = load $args[0]

play $p1 $p2 $false
play $p1 $p2 $true
