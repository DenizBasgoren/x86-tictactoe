# x86-tictactoe
Tic Tac Toe Game implementation in x86 Assembly using GNU+Linux.

![screenshot](https://denizbasgoren.github.io/x86-tictactoe/screenshots/ss.png)

# How to compile
Before compiling, make sure you have NASM, and GCC installed. Note that this program works only on x86 compatible processors and only on GNU+Linux operating system. First step is to assemble the program using NASM:

```
nasm -f elf32 -g -F dwarf tictactoe.asm
```

Next, we need to use a linker. ld would be appropriate, however, since we need to import `time`, `rand`, and `srand` functions from standard C library, we use GCC's builtin linker. Locate where `libstdc++.a` (the C std library) is in your system. For example, mine was in `/lib/libstdc++.a`. Now call the linker:

```
gcc -m32 -I/lib/libstdc++.a tictactoe.o -o tictactoe
```

Note: change `/lib/libstdc++.a` with your own stdlib path.

Now run the game:

```
./tictactoe
```

Enjoy!

# How to play

Cells are numbered as following:

```
   -   -   -  
 | 1 | 2 | 3 |
   -   -   -  
 | 4 | 5 | 6 |
   -   -   -  
 | 7 | 8 | 9 |
   -   -   -  
```

You play always with Xs. AI player plays with Os. When it's your turn, type the number of the cell you would like to place your X on.

# Flowchart

Flowcharts demonstrating how the code works are included in the repository under the name `Flow.pdf`

