# *BASH-SCRIPTS*

This repository is a collection of bash scripts that I have made.

To play with any of the files here, simply clone the repository and run the scripts from bash. For example, to play Mastermind:

```
$ git clone https://github.com/nelsonwalker/bash-scripts.git
$ cd bash-scripts/
$ ./mastermind.sh
```

## mastermind.sh ##

This game is a code breaking game. The code is a sequence of unique letters from A-H of length 5. You have 8 attempts to guess the code, and each guess provides clues to the code. There are no special commands made for mastermind yet.

Making this program helped me learn the basics of loops in bash scripts, handling user input, and some more advanced techniques for printing the the screen.

## tictactoe.sh ##

To play against a friend, simply execute `$ ./tictactoe.sh`. To play against the computer, provide the -c flag: `$ ./tictactoe.sh -c`.

After learning some of the basic elements of bash scripting, I took on the challenge of developing a noughts & crosses program which could be played as one user against another or against the computer.

To simplify things, the computer always plays as crosses. My first challenge was representing the board; since there aren't really any types in bash scripts like there are in normal programming languages, I came up with a simple 'data structure' which was simply a variable containing 9 characters. Each character represents the token occupying a certain square on the board (either '-' for blank, X, or O). I then made functions to update the board and extract information from it.

The next big challenge was coming up with an algorithm for choosing moves. I originally thought it would be interesting to try and implement the minimax algorithm, but after giving it some more thought I decided it would be too difficult to do in the bash scripting language, which doesn't provide much of the functionality required for such an algorithm. However, I ended up creating an evaluation function which just looks at the immediate possible moves, i.e. minimax with depth 1. 

The evaluation function tries to maximise the number of rows, columns, or diagonals with only X's on them, valuing columns with double X's three times higher than single X's. While this simple method works surprisingly well for many inputs, the lack of depth in the search means it does not consider possible moves from O and thus sometimes fails to block an obvious defeat. As this was all done using basic shell commands and programs such as sort, awk, echo, head, tail, etc, I think that this is overall not a bad result. I think it would not be too difficult to extend the logic to a search that goes in more depth in an actual programming language like C or python. 
