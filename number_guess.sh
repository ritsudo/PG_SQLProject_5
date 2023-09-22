#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"
echo "Enter your username:"
read USER_NAME

#check db if user exists
USER_SEARCH_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USER_NAME'")

if [[ -z $USER_SEARCH_RESULT ]]
then
  USER_INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USER_NAME')")
  if [[ $USER_INSERT_RESULT == "INSERT 0 1" ]]
  then
    echo "Welcome, $USER_NAME! It looks like this is your first time here."
  fi
else
  GAMES_SEARCH_RESULT=$(echo $($PSQL "SELECT games_played FROM users WHERE username='$USER_NAME'") | sed 's/ |/"/')
  if [[ $GAMES_SEARCH_RESULT ]]
  then
    BEST_GAME_SEARCH_RESULT=$(echo $($PSQL "SELECT best_game FROM users WHERE username='$USER_NAME'") | sed 's/ |/"/')
    if [[ $BEST_GAME_SEARCH_RESULT ]]
    then
     echo -e "\nWelcome back, $USER_NAME! You have played $GAMES_SEARCH_RESULT games, and your best game took $BEST_GAME_SEARCH_RESULT guesses."
    fi
  fi
fi

GAMES_SEARCH_RESULT=$((GAMES_SEARCH_RESULT+1))
GAMES_UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_SEARCH_RESULT WHERE username='$USER_NAME';")

RANDOM_NUMBER=$(shuf -i 1-1000 -n 1)
TRIES_COUNT=0
echo "Guess the secret number between 1 and 1000:"

#debug
#echo $RANDOM_NUMBER

MAIN() {
TRIES_COUNT=$((TRIES_COUNT+1))
read GUESS_INPUT

if [[ ! $GUESS_INPUT =~ ^[0-9]+$ ]]
then
  echo "That is not an integer, guess again:"
  MAIN
fi

if [[ $GUESS_INPUT < $RANDOM_NUMBER ]]
then
    echo "It's lower than that, guess again:"
    MAIN
  else
  if [[ $GUESS_INPUT > $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    MAIN
  else 
    if [[ $GUESS_INPUT == $RANDOM_NUMBER ]]
    then
    #score update

    #echo $TRIES_COUNT, $BEST_GAME_SEARCH_RESULT
    if [[ $TRIES_COUNT -lt $BEST_GAME_SEARCH_RESULT ]]
    then
      SCORE_UPDATE_RESULT=$($PSQL "UPDATE users SET best_game=$TRIES_COUNT WHERE username='$USER_NAME';")
    fi
    #end score update
    echo "You guessed it in $TRIES_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
    fi
  fi
fi
}

MAIN
