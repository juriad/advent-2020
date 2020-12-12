function! Step(line)
    let command = a:line[0]
    let number = a:line[1:]

    if command == 'N'
        let g:Y += number
    elseif command == 'S'
        let g:Y -= number
    elseif command == 'E'
        let g:X += number
    elseif command == 'W'
        let g:X -= number
    elseif command == 'L'
        if number < 100
            let g:D = (g:D + 3) % 4
        elseif number < 200
            let g:D = (g:D + 2) % 4
        else
            let g:D = (g:D + 1) % 4
        endif
    elseif command == 'R'
        if number < 100
            let g:D = (g:D + 1) % 4
        elseif number < 200
            let g:D = (g:D + 2) % 4
        else
            let g:D = (g:D + 3) % 4
        endif
    elseif command == 'F'
        if g:D == 0
            let g:X += number
        elseif g:D == 1
            let g:Y -= number
        elseif g:D == 2
            let g:X -= number
        elseif g:D == 3
            let g:Y += number
        endif
    endif
endfunction

function! WStep(line)
    let command = a:line[0]
    let number = a:line[1:]

    if command == 'N'
        let g:WY += number
    elseif command == 'S'
        let g:WY -= number
    elseif command == 'E'
        let g:WX += number
    elseif command == 'W'
        let g:WX -= number
    elseif command == 'L'
        if number < 100
            let x = g:WX
            let g:WX = -g:WY
            let g:WY = x
        elseif number < 200
            let g:WX = -g:WX
            let g:WY = -g:WY
        else
            let x = g:WX
            let g:WX = g:WY
            let g:WY = -x
        endif
    elseif command == 'R'
        if number < 100
            let x = g:WX
            let g:WX = g:WY
            let g:WY = -x
        elseif number < 200
            let g:WX = -g:WX
            let g:WY = -g:WY
        else
            let x = g:WX
            let g:WX = -g:WY
            let g:WY = x
        endif
    elseif command == 'F'
        let g:X += g:WX * number
        let g:Y += g:WY * number
    endif
endfunction

function! Steps()
    let g:X = 0
    let g:Y = 0
    let g:D = 0

    let linenr = 0
    while linenr < line("$")
        let linenr += 1
        let line = getline(linenr)
        call Step(line)
    endwhile
endfunction

function! WSteps()
    let g:WX = 10
    let g:WY = 1

    let g:X = 0
    let g:Y = 0

    let linenr = 0
    while linenr < line("$")
        let linenr += 1
        let line = getline(linenr)
        call WStep(line)
    endwhile
endfunction

execute "redir >> /dev/stdout"

call Steps()
echo abs(g:X) + abs(g:Y)

call WSteps()
echo abs(g:X) + abs(g:Y)

execute "q"
