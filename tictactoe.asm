

; COMPILATION
; nasm -f elf32 -g -F dwarf tictactoe.asm
; gcc -m32 -I/lib/libstdc++.a tictactoe.o -o tictactoe
; tictactoe


section .data
    title: db "XOX Game by Deniz Basgoren", 10, 10
    titleLen: equ $ - title
    instruction: db "Enter the number of cell (1-9) to put X on: "
    instructionLen: equ $ - instruction
    fullError: db "Cannot put X on cell . because this cell is full.", 10
    fullErrorLen: equ $ - fullError
    oobError: db "No such cell. Cells are numbered 1-9.", 10
    ; oob: out of bounds
    oobErrorLen: equ $ - oobError
    win: db "You won! Restart? (y/n)", 10
    winLen: equ $ - win
    fail: db "You failed! Restart? (y/n)", 10
    failLen: equ $ - fail
    tie: db "Tie! Restart? (y/n)", 10
    tieLen: equ $ - tie
    escape: db 27, "[2J", 27, "[1;1H"
    escapeLen: equ $ - escape
    boardBorder1: db "   -   -   -  ", 10
    boardBorder1Len: equ $ - boardBorder1
    boardBorder2: db " | . | . | . |", 10
    boardBorder2Len: equ $ - boardBorder2
    
    board: times 9 db ' '  ; ' ', 'X', 'O'
    fullErrorIsVisible: db 0    ; 0 no, 1 yes 
    oobErrorIsVisible: db 0    ; 0 no, 1 yes 
    gameStatus: db 0        ; 0 on, 1 failed, 2 won, 3 tied
    


section .bss
    input: resb 1
    dummy: resb 1

section .text
global main

extern time
extern srand
extern rand

main:
    nop

    ; system clear
    mov eax, 4
    mov ebx, 1
    mov ecx, escape
    mov edx, escapeLen
    int 80h

    ; draw title
    mov eax, 4
    mov ebx, 1
    mov ecx, title
    mov edx, titleLen
    int 80h

    call drawBoard


    ; gs ?
    mov al, byte [gameStatus]
    cmp al, 1
    jl gameIsOn
    je gameFailed
    
    cmp al, 3
    jl gameWon
    jmp gameTied

; expects char in ascii to be in eax.
printChar:
    ; save
    push ebx
    push ecx
    push edx
    push eax ; esp points to the char

    ; print
    mov eax, 4
    mov ebx, 1
    sub ecx, 4
    mov ecx, esp
    mov edx, 1
    int 80h

    ; restore
    pop eax
    pop edx
    pop ecx
    pop ebx
    ret

    



drawBoard:
    push eax
    push ebx
    push ecx
    push edx
    push board

    .L1:
    mov eax, 4
    mov ebx, 1
    mov ecx, boardBorder1
    mov edx, boardBorder1Len
    int 80h

    pop edx
    mov al, byte [edx]
    mov ecx, boardBorder2
    mov ebx, 3
    call editByte

    add edx, 1
    mov al, byte [edx]
    mov ebx, 7
    call editByte

    add edx, 1
    mov al, byte [edx]
    mov ebx, 11
    call editByte

    add edx, 1
    push edx

    mov eax, 4
    mov ebx, 1
    mov ecx, boardBorder2
    mov edx, boardBorder2Len
    int 80h

    pop edx
    cmp edx, board+9
    push edx
    jne .L1

    pop edx
    mov eax, 4
    mov ebx, 1
    mov ecx, boardBorder1
    mov edx, boardBorder1Len
    int 80h

    mov eax, 10
    call printChar

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

exit:  
    mov eax, 1
    mov ebx, 0
    int 80h


gameIsOn:

    ; print fullError?
    cmp byte [fullErrorIsVisible], 1
    jne .skipFullErrorLogging; skip error msg

        ; edit byte
        mov al, byte [input]
        mov ebx, 21
        mov ecx, fullError
        call editByte

        ; error msg
        mov eax, 4
        mov ebx, 1
        mov edx, fullErrorLen
        int 80h

    .skipFullErrorLogging:

    ; print oebError?
    cmp byte [oobErrorIsVisible], 1
    jne .skipOobErrorLogging; skip error msg

        ; error msg
        mov eax, 4
        mov ebx, 1
        mov ecx, oobError
        mov edx, oobErrorLen
        int 80h

    .skipOobErrorLogging:

    ; oev = 0, fev = 0
    mov byte [fullErrorIsVisible], 0
    mov byte [oobErrorIsVisible], 0

    ; instruction msg
    mov eax, 4
    mov ebx, 1
    mov ecx, instruction
    mov edx, instructionLen
    int 80h

    ; input 1-9
    call getChar
    
    ; i > 0?
    cmp byte [input], '1'
    jge .skipOobErrorRedirect ;no oob error

        ; oob error!
        mov byte [oobErrorIsVisible], 1
        jmp main

    .skipOobErrorRedirect:

    ; i < 10?
    cmp byte [input], '9'
    jle .skipOobErrorRedirect2 ;no oob error

        ; oob error!
        mov byte [oobErrorIsVisible], 1
        jmp main

    .skipOobErrorRedirect2:


    ; board[input] = ' '?
    xor eax, eax
    mov al, byte [input]
    sub al, '1'
    mov ebx, board
    add ebx, eax
    mov al, byte [ebx]
    cmp al, ' '
    je .skipFullErrorRedirect ;no full error

        ; full error!
        mov byte [fullErrorIsVisible], 1
        jmp main

    .skipFullErrorRedirect:

    ; enter the X
    mov byte [ebx], 'X'
    
    mov al, 'X'
    call isGameOver
    cmp ah, 0
    je .isTie

        mov byte [gameStatus], 2
        jmp main

    .isTie:
    call areAnyMovesLeft
    cmp ah, 1
    je .cpuMove

        mov byte [gameStatus], 3
        jmp main

    .cpuMove:
    call cpuAlgorithm

    mov al, 'O'
    call isGameOver
    cmp ah, 0
    je .isTieAgain

        mov byte [gameStatus], 1
        jmp main

    .isTieAgain:
    call areAnyMovesLeft
    cmp ah, 1
    je .notTie

        mov byte [gameStatus], 3
        jmp main

    .notTie:
    jmp main











gameWon:

    mov eax, 4
    mov ebx, 1
    mov ecx, win
    mov edx, winLen
    int 80h

    call getChar

    cmp byte [input], 'y'
    jne exit
    mov byte [gameStatus], 0
    call cleanBoard
    jmp main


gameFailed:

    mov eax, 4
    mov ebx, 1
    mov ecx, fail
    mov edx, failLen
    int 80h

    call getChar

    cmp byte [input], 'y'
    jne exit
    mov byte [gameStatus], 0
    call cleanBoard
    jmp main

gameTied:

    mov eax, 4
    mov ebx, 1
    mov ecx, tie
    mov edx, tieLen
    int 80h

    call getChar

    cmp byte [input], 'y'
    jne exit
    mov byte [gameStatus], 0
    call cleanBoard
    jmp main


getChar:
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 1
    int 80h

    cmp byte [input], 10
    jne .L1
    ret

    .L1:
    mov eax, 3
    mov ebx, 0
    mov ecx, dummy
    mov edx, 1
    int 80h

    cmp byte [dummy], 10
    jne .L1
    ret

; expects base address in ecx, offset in ebx, and new val in al
editByte:
    push eax
    push ebx
    push ecx
    push edx

    add ecx, ebx
    mov byte [ecx], al

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; expects side ('X' or 'O') at al. returns 1=yes 0=no to ah.
isGameOver:

    xor ah, ah
    push ebx

    mov bl, byte [board+0]
    cmp bl, al
    jne .step2

    mov bl, byte [board+3]
    cmp bl, al
    jne .step2
    
    mov bl, byte [board+6]
    cmp bl, al
    jne .step2
    jmp .yes

    .step2:
    mov bl, byte [board+1]
    cmp bl, al
    jne .step3

    mov bl, byte [board+4]
    cmp bl, al
    jne .step3
    
    mov bl, byte [board+7]
    cmp bl, al
    jne .step3
    jmp .yes

    .step3:
    mov bl, byte [board+2]
    cmp bl, al
    jne .step4

    mov bl, byte [board+5]
    cmp bl, al
    jne .step4
    
    mov bl, byte [board+8]
    cmp bl, al
    jne .step4
    jmp .yes

    .step4:
    mov bl, byte [board+0]
    cmp bl, al
    jne .step5

    mov bl, byte [board+1]
    cmp bl, al
    jne .step5
    
    mov bl, byte [board+2]
    cmp bl, al
    jne .step5
    jmp .yes

    .step5:
    mov bl, byte [board+3]
    cmp bl, al
    jne .step6

    mov bl, byte [board+4]
    cmp bl, al
    jne .step6
    
    mov bl, byte [board+5]
    cmp bl, al
    jne .step6
    jmp .yes

    .step6:
    mov bl, byte [board+6]
    cmp bl, al
    jne .step7

    mov bl, byte [board+7]
    cmp bl, al
    jne .step7
    
    mov bl, byte [board+8]
    cmp bl, al
    jne .step7
    jmp .yes

    .step7:
    mov bl, byte [board+0]
    cmp bl, al
    jne .step8

    mov bl, byte [board+4]
    cmp bl, al
    jne .step8
    
    mov bl, byte [board+8]
    cmp bl, al
    jne .step8
    jmp .yes

    .step8:
    mov bl, byte [board+2]
    cmp bl, al
    jne .no

    mov bl, byte [board+4]
    cmp bl, al
    jne .no
    
    mov bl, byte [board+6]
    cmp bl, al
    jne .no
    jmp .yes

    .no:
    mov ah, 0
    pop ebx
    ret

    .yes:
    mov ah, 1
    pop ebx
    ret


cleanBoard:
    push eax
    mov eax, 0

    .loop:
    mov byte [board+eax], ' '
    inc eax
    cmp eax, 9
    jne .loop

    pop eax
    ret

; returns 1=yes 0=no to ah.
areAnyMovesLeft:
    mov eax, board

    .loop:
    cmp byte [eax], ' '
    je .yes
    inc eax

    cmp eax, board+9
    jne .loop
    jmp .no

    .no:
    mov ah, 0
    ret

    .yes:
    mov ah, 1
    ret
    


cpuAlgorithm:

    mov ecx, 0

    .loop1:

    cmp ecx, 9
    je .noWinningPositions

    cmp byte [board+ecx], ' '
    je .cellIsEmpty
    jne .cellIsFull

    .cellIsFull:
    inc ecx
    jmp .loop1

    .cellIsEmpty:
    mov byte [board+ecx], 'O'
    mov al, 'O'
    call isGameOver
    cmp ah, 1
    jne .notWinningPosition
    ret

    .notWinningPosition:
    mov byte [board+ecx], ' '
    inc ecx

    jmp .loop1

    .noWinningPositions:

    mov ecx, 0
    
    .loop2:
    cmp ecx, 9
    je .moveRandomly

    cmp byte [board+ecx], ' '
    je .cellIsEmpty2
    inc ecx
    jmp .loop2

    .cellIsEmpty2:
    mov byte [board+ecx], 'X'
    mov al, 'X'
    call isGameOver
    cmp ah, 1
    je .preventWin
    
    mov byte [board+ecx], ' '
    inc ecx
    jmp .loop2

    .preventWin:
    mov byte [board+ecx], 'O'
    ret
    
    .moveRandomly:

    ; srand( time(0) )
    push dword 0
    call time
    add esp, 4
    push eax
    call srand
    add esp, 4

    .loop3:

    ; offset = rand() / ( 2^32 / 9 )
    call rand
    mov ecx, 9
    div ecx

    cmp byte [board+edx], ' '
    jne .loop3

    mov byte [board+edx], 'O'
    ret

