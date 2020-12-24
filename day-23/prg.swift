import Foundation

class Cup {
    let value: Int
    var smaller: Cup!

    var prev: Cup!
    var next: Cup!
    var isPicked: Bool

    init(value: Int) {
        self.value = value
        self.isPicked = false
    }

    func pickNext3() -> Cup {
        var n = next!
        for _ in 1...3 {
            n.isPicked = true
            n = n.next
        }
        let picked = next!

        next = n
        n.prev = self

        return picked
    }

    func place(picked: Cup) {
        let n = next!

        var p = picked
        next = p
        p.prev = self

        for _ in 1...2 {
            p.isPicked = false
            p = p.next
        }
        p.isPicked = false

        p.next = n
        n.prev = p
    }

    func findDest() -> Cup {
        var d = self.smaller!
        while d.isPicked {
            d = d.smaller
        }
        return d
    }

    func printCup() {
        print("val: \(value); smaller: \(smaller.value); prev: \(prev.value); next: \(next.value)")
    }
}

class Game {
    let cups: [Cup]
    var current: Cup

    init(input: [Int], size: Int) {
        var cs = [Cup]()
        for i in 0..<size {
            var c: Cup
            if (i < input.count) {
                c = Cup(value: input[i])
            } else {
                c = Cup(value: i + 1)
            }

            if (i > 0) {
                cs[i - 1].next = c
                c.prev = cs[i - 1]
            }
            if (i > input.count) {
                c.smaller = cs[i - 1]
            }
            cs.append(c)
        }
        cs[0].prev = cs[size - 1]
        cs[size - 1].next = cs[0]

        let max = size > input.count ? input.count : input.count - 1
        for i in 0...max {
            let search: Int
            if cs[i].value == 1 {
                if size > input.count {
                    cs[i].smaller = cs[size - 1]
                    continue
                }
                search = input.count
            } else {
                search = cs[i].value - 1
            }
            for j in 0...input.count {
                if cs[j].value == search {
                    cs[i].smaller = cs[j]
                    break
                }
            }

            // cs[i].printCup()
        }

        cups = cs
        current = cups[0]
    }

    func printGame() {
        var c = current
        repeat {
            print("\(c.value)", terminator: " ")
            c = c.next
        } while (c !== current)
        print()
    }

    func move() {
        let picked = current.pickNext3()
        let dest = current.findDest()
        dest.place(picked: picked)
        current = current.next
    }
}

func task1(input:[Int]) {
    let g = Game(input:input, size:input.count)
    // g.printGame()
    for _ in 1...100 {
        g.move()
        // g.printGame()
    }

    var c = g.current
    while c.value != 1 {
        c = c.next
    }

    c = c.next
    repeat {
        print(c.value, terminator: "")
        c = c.next
    } while (c.value != 1)
    print()
}

func task2(input: [Int]) {
    let g = Game(input:input, size: 1000000)
    for _ in 1...10000000 {
        g.move()
    }

    var c = g.current
    while c.value != 1 {
        c = c.next
    }

    let c1 = c.next.value
    let c2 = c.next.next.value
    print("\(c1) * \(c2) = \(c1 * c2)")
}

func processFile(file:String) {
    let contents = try! String(contentsOfFile: filename)
    let lines = contents.split(separator:"\n")

    for line in lines {
        var input = [Int]()
        for c in line {
            input.append(c.wholeNumberValue!)
        }

        task1(input: input)
        task2(input: input)
    }
}

let filename = CommandLine.arguments[1]
processFile(file: filename)
