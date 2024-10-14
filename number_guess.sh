#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAGIC_NUMBER=$((1 + $RANDOM % 1000))

echo "Enter your username:"

read USERNAME

USERNAME_FROM_DATABASE=$($PSQL "SELECT username FROM number_guess WHERE username='$USERNAME'")

if [[ -z $USERNAME_FROM_DATABASE ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."

else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM number_guess WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best FROM number_guess WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

MENU () {
read GUESS
if [[ ! "$GUESS" =~ ^[0-9]+$ ]]
then
  echo "That is not an integer, guess again:"
  MENU $1
fi

count=$(($1+1))
if [[ $GUESS -eq $MAGIC_NUMBER ]]
then
  echo "You guessed it in $count tries. The secret number was $MAGIC_NUMBER. Nice job!"

  if [[ -z $USERNAME_FROM_DATABASE ]]
  then
    INSERT_NEW_USER=$($PSQL "INSERT INTO number_guess(username,games_played,best) VALUES('$USERNAME', 1, $count)")
  
    if [[ $INSERT_NEW_USER == "INSERT 0 1" ]]
      then
        exit
    fi
  fi
      
  UPDATE_USER_1=$($PSQL "UPDATE number_guess SET games_played=$GAMES_PLAYED+1 WHERE username='$USERNAME'")
  if [[ $count -lt $BEST_GAME ]]
  then
    UPDATE_USER_2=$($PSQL "UPDATE number_guess SET best=$count WHERE username='$USERNAME'")
  fi
  exit
fi

if [[ $GUESS -lt $MAGIC_NUMBER ]]
then
  echo "It's higher than that, guess again:"
  MENU $count
else
  echo "It's lower than that, guess again:"
  MENU $count
fi


}

MENU 0
