#!/bin/bash 
# each digit represents the status of a square: - = clear, O = circle, X = cross
BOARD=---------
WINNER=FALSE
PLAYER='X'

# usage: update_board [DIGIT] [STATE] [BOARD], e.g. update_board 1 X. Note that indexing starts at 1. [BOARD] defaults to global variable BOARD.
# If a third argument is passed, update_board outputs the result of the update rather than updating the variable
function update_board {
	if [ $# -lt 2 ] 
	then
		echo error: wrong numargs to update_board
		exit
	fi
	if [ $# -eq 3 ]; then 
		echo $3 | sed s/./$2/$1 
	else
		BOARD=$( echo $BOARD | sed s/./$2/$1 )
	fi
}

# find what symbol is in a given position. Usage: get_state [DIGIT] [BOARD]. Defaults to global BOARD.
function get_state {
	if [ $# -lt 1 ]
	then
		echo error: wrong number of arguments. Usage: get_state [DIGIT] [BOARD]
		exit
	elif [[ ! $1 =~ [0-8] ]]
	then
		echo error: get_state passed non integer
		exit
	elif [[ $# -eq 2 ]]
	then
		BRD=$2
		echo ${2:$1:1}
	else
		echo ${BOARD:$1:1}
	fi
}


# optional [BOARD] argument
function print_board {
	for i in {0..8}
	do
		if [ $# -gt 0 ]; then STATE=$( get_state $i $1 )
		else STATE=$( get_state $i ); fi
		echo -n $STATE
		if (( ($i + 1) % 3 == 0 ))
		then
			echo
		else
			echo -n \|
		fi
	done
}


# check if a given column is uniform. Usage: check_col [COL] where COL in {0, 1, 2}
function check_col {
	if [ $( get_state $1 ) = $( get_state $(( $1 + 3 )) ) ] && \
		[ $( get_state $1 ) = $( get_state $(( $1 + 6 )) ) ] && \
		[ $( get_state $1 ) != "-" ]
	then
		echo "TRUE"
	else
		echo "FALSE"
	fi
}

function check_row {
	if [ $( get_state $(( $1*3 )) ) = $( get_state $(( $1*3+1 )) ) ] && \
		[ $( get_state $(( $1*3 )) ) = $( get_state $(( $1*3+2 )) ) ] && \
	   [ $( get_state $(( $1*3 )) ) != "-" ]
	then
		echo "TRUE"
	else
		echo "FALSE"
	fi
}

function check_diags {
	if [ $( get_state 0 ) = $( get_state 4 ) ] && \
	   [ $( get_state 0 ) = $( get_state 8 ) ] && \
	   [ $( get_state 0 ) != "-" ] 
	then
		echo "TRUE"
	elif [ $( get_state 6 ) = $( get_state 4 ) ] && \
	   [ $( get_state 6 ) = $( get_state 2 ) ] && \
	   [ $( get_state 6 ) != "-" ]
	then
		echo "TRUE"
	else
		echo "FALSE"
	fi
}

function check_draw {
	if ! [[ $BOARD == *"-"* ]]
	then
		echo "TRUE"
	else
		echo "FALSE"
	fi
}

function check_win {
	for i in {0..2}
	do
		if [ $( check_row $i ) = TRUE ]
		then
			echo Winner: $( get_state $i )
			exit
		fi
		if [ $( check_col $i ) = TRUE ]
		then
			echo Winner: $( get_state $i )
			exit
		fi
	done
	if [ "$( check_diags )" = TRUE ]
	then
		echo Winner: $( get_state 4 )
		exit
	fi
	if [ $( check_draw ) = TRUE ]
	then
		echo Draw!
		exit
	fi
	echo FALSE
}

function swap_player {
	if [ $PLAYER = 'X' ]
	then
		PLAYER='O'
	else
		PLAYER='X'
	fi
}

# Option to play against the computer
VSPC=FALSE
if [ $# -gt 0 ] && [ $1 = '-c' ]
then
	VSPC=TRUE
	read -p 'Would you like to go first? [y/n] ' ORDER
	if [ $ORDER = y ]
	then
		# PC always plays as X
		PLAYER='O'
	elif [ $ORDER = n ]
	then
		PLAYER='X'
	else
		echo error: invalid response
		exit
	fi
fi


# n_in_a_row = number of rows/columns/diagonals with exactly n X's and zero O's, or vice versa, depending on option used.
# Usage: n_in_a_row [BOARD] [X/O] [n]
function n_in_a_row {
	if [ ! $# -eq 3 ]
	then
		echo error: wrong numargs passed into X_n
		exit
	elif [[ ! $2 =~ [XO] ]]
	then
		echo error: 2nd arg $2 not one of [XO]
		exit
	elif [[ ! $3 =~ [1-3] ]]
	then
		echo error: n not in correct range
		exit
	fi
	n=$3
	SIDE=$2
	TMPBOARD=$1
	if [ $SIDE = X ]
	then
		OTHER='O'
	else
		OTHER='X'
	fi
	
	COUNT=0
	for i in {0..2}
	do
		# rows
		CURRENT_ROW=0
		for j in {0..2}
		do
			STATE=$( get_state $(( $i * 3 + j )) $TMPBOARD )
			if [[ $STATE == $OTHER ]]
			then
				CURRENT_ROW=0
				break
			elif [[ $STATE == $SIDE ]]
			then
				(( CURRENT_ROW++ ))
			fi
		done
		if [ $CURRENT_ROW -eq $n ]
		then
			(( COUNT++ ))
		fi

		# columns
		CURRENT_COL=0
		for j in {0..2}
		do
			STATE=$( get_state $(( $i + 3 * j )) $TMPBOARD )
			if [[ $STATE == $OTHER ]]
			then
				CURRENT_ROW=0
				break
			elif [[ $STATE == $SIDE ]]
			then
				(( CURRENT_COL++ ))
			fi
		done
		if [ $CURRENT_COL -eq $n ]
		then
			(( COUNT++ ))
		fi
	done

	# top left to bottom right diagonal
	CURRENT_DIAG=0
	for i in {0..8..4}; do
		STATE=$( get_state $i $TMPBOARD )
		if [ $STATE = $OTHER ]; then
			CURRENT_DIAG=0
			break
		elif [ $STATE = $SIDE ]; then 
			(( CURRENT_DIAG++ ))
		fi
	done
	if [ $CURRENT_DIAG -eq $n ]; then (( COUNT++ )); fi
	# top right to bottom left
	CURRENT_DIAG=0
	for i in {2..6..2}; do
		STATE=$( get_state $i $TMPBOARD )
		if [ $STATE = $OTHER ]; then
			CURRENT_DIAG=0
			break
		elif [ $STATE = $SIDE ]; then 
			(( CURRENT_DIAG++ ))
		fi
	done
	if [ $CURRENT_DIAG -eq $n ]; then (( COUNT++ )); fi

	echo $COUNT
}

# evaluates a specific position: evaluate [BOARD]
# Eval = 3X(2) + X(1) - ( 3O(2) + O(1))
function evaluate {
	if [ ! $# -eq 1 ]; then echo error: wrong numargs passed to evaluate; exit; fi
	X_3=$( n_in_a_row $1 X 3 )
	X_2=$( n_in_a_row $1 X 2 )
	X_1=$( n_in_a_row $1 X 1 )
	O_3=$( n_in_a_row $1 O 3 )
	O_2=$( n_in_a_row $1 O 2 )
	O_1=$( n_in_a_row $1 O 1 )
	#echo "X(3) = $X_3, X(2) = $X_2, X(1) = $X_1, O(3) = $O_3, O(2) = $O_2, O(1) = $O_1"
	echo $(( 1000 * $X_3 + 3 * $X_2 + $X_1 - 1000 * $O_3 - 3 * O_2 - O_1 ))
}

# function to build a list of evaluations of all possible positions using hueristic
function movescores {
	# need a list of possible moves we can make, then make them
	POSMOVES=$( echo $BOARD | grep -aob '-' | grep -oE '[0-9]' )
	BOARDCPY=$BOARD
	for MOVE in $POSMOVES; do
		BOARDCPY=$( update_board $(( $MOVE + 1 )) X $BOARDCPY )
		echo -n "$(( $MOVE + 1 )) "
		evaluate $BOARDCPY
		BOARDCPY=$BOARD
	done
}

# look at all possible moves and choose the best one based on the list produced in movescores
function choose_move {
	echo $( movescores | sort -g -k2 | tail -1 | awk '{print $1}' )
}


while [ "$WINNER" = FALSE ]
do
	print_board
	if [ $VSPC = FALSE ] || [ $PLAYER = 'O' ]
	then
		read -p 'Enter your next move [1-9]: ' MOVE
	else
		echo computer moving:
		MOVE=$( choose_move )
	fi
	VALID='[0-9]'
	if [[ ! $MOVE =~ $VALID ]] || [ $( get_state $(($MOVE - 1)) ) != "-" ]
	then
		echo error: please enter a valid move
		continue
	fi
	update_board $MOVE $PLAYER
	swap_player
	WINNER=$( check_win )
done
print_board
echo $WINNER

