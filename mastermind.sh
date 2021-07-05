#!/bin/bash

# a program for playing the game mastermind

GREEN='\033[0;32m'
LIGHTBLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m'
LG='\033[0;37m'
PURPLE='\033[0;35m'

INSYMB=${GREEN}*${NC}
OUTSYMB=${LIGHTBLUE}^${NC}
NOTINSYMB=${RED}-${NC}

echo -e "Welcome to Mastermind.\nThe aim is to work out a 5 letter sequence of unique letters from A-H in 8 guesses.\nTo begin, simply enter your guess for the code, e.g. A B C D E.\nAfter your guess, you will receive feedback on your guess:\nEach '${INSYMB}' indicates one character is in the code and in the right spot.\nEach '${OUTSYMB}' indicates one character is in the code but in the wrong spot.\nEach '${NOTINSYMB}' indicates one character is not in the code.\nNote: these symbols are not in any particular order.\n\n\nGood luck!\n\n\n"

# generate random ordering of letters by associating each letter with a random
# number, sorting the list, then removing the numbers

i=1
RANDNUMS="${RANDOM}A\n"
LETTERS="B\nC\nD\nE\nF\nG\nH"
while [ $i -lt 8 ]
do
	RANDNUMS="${RANDNUMS}\n${RANDOM}$( echo -e $LETTERS | head -$i | tail -1)"
	(( i++ ))
done
RANDNUMS=$(echo -e $RANDNUMS | sort -n | head -6)
CODE=$( echo -e $RANDNUMS | sed 's/[0-9]*//g' )

for row in {1..8}
do
	read GUESS
	OUTPLACE=0
	INPLACE=0
	i=1
	for TRUEVAL in $CODE
	do
		j=1
		for GUESSVAL in $GUESS
		do
			if [[ $TRUEVAL = $GUESSVAL && ! $i -eq $j ]]
			then
				(( OUTPLACE++ ))
			elif [[ $TRUEVAL = $GUESSVAL && $i -eq $j ]]
			then
				(( INPLACE++ ))
			fi
			(( j++ ))
		done
	(( i++ ))
	done
	
	NOTINCODE=$(( 5 - $INPLACE - $OUTPLACE ))

	# visual representation of guess correctness printed on same line as prompt
	echo -en "\033[1A\033[2K" # found on stackexchange
	echo -en "$GUESS ${PURPLE}|"
	INPLACECPY=$INPLACE
	while [ $INPLACECPY -gt 0 ]
	do
		echo -en $INSYMB
		(( INPLACECPY-- ))
	done
	while [ $OUTPLACE -gt 0 ]
	do
		echo -en $OUTSYMB	
		(( OUTPLACE-- ))
	done
	while [ $NOTINCODE -gt 0 ]
	do
		echo -en $NOTINSYMB
		(( NOTINCODE-- ))
	done
	echo -e "\n${PURPLE}-----------------${NC}"
	
	if [ $INPLACE -eq 5 ]
	then
		echo -e "\nCongratulations! You win!"
		exit
	fi


done
echo Better luck next time!
