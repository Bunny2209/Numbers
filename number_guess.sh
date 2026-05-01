#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME
if [[ ${#USERNAME} -lt 22 ]]
then
  EXISTS=$($PSQL "select user_id from users where name='$USERNAME'")
  if [[ -z $EXISTS ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER_NAME=$($PSQL "insert into users(name) values('$USERNAME')")
  else
    USER_ID=$($PSQL "select user_id from users where name='$USERNAME'")
    NO_OF_GAMES=$($PSQL "select count(*) from games where user_id=$USER_ID")
    BEST_GAME=$($PSQL "select min(guesses) from games where user_id=$USER_ID")
    echo "Welcome back, $USERNAME! You have played $NO_OF_GAMES games, and your best game took $BEST_GAME guesses."
  fi
  COUNTER=0
  echo "Guess the secret number between 1 and 1000:"
  read READ_NUMBER
  ((COUNTER++))
  RANDOM_NUMBER=$(( (RANDOM % 1000) + 1 ))
  while [[ ! $READ_NUMBER =~ ^[0-9]*$ ]]
  do
    echo "That is not an integer, guess again:"
    read READ_NUMBER
  done
  while [[ $READ_NUMBER =~ ^[0-9]*$ ]]
  do
    if [[ $RANDOM_NUMBER -gt $READ_NUMBER  ]]
    then
      echo "It's lower than that, guess again:"
      read READ_NUMBER
      ((COUNTER++))
    elif [[ $RANDOM_NUMBER -lt $READ_NUMBER  ]]
    then
      echo "It's higher than that, guess again:"
      read READ_NUMBER
      ((COUNTER++))
    else
      echo "You guessed it in $COUNTER tries. The secret number was $RANDOM_NUMBER. Nice job!"
      USER_ID=$($PSQL "select user_id from users where name='$USERNAME'")
      INSERT_GAME=$($PSQL "insert into games(user_id,guesses) values($USER_ID,$COUNTER)")
      break
    fi
  done
fi
