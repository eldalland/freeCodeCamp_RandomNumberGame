#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
MAIN_MENU(){
  echo "Enter your username:"
  read USERNAME
  RAND_NUM=$((RANDOM % 1000 +1 ))
  USER_ID=$($PSQL "SELECT user_id FROM user_data WHERE username = '$USERNAME'")
  if [[ $USER_ID ]]
  then
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_data WHERE user_id= '$USER_ID'")
    BEST_GAME=$($PSQL "SELECT best_game FROM user_data WHERE user_id ='$USER_ID'")
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  else
    INSERT_NAME=$($PSQL "INSERT INTO user_data(username) VALUES('$USERNAME')")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    USER_ID=$($PSQL "SELECT user_id FROM user_data WHERE username = '$USERNAME'")
  fi

  GUESSES=0
  echo "Guess the secret number between 1 and 1000:"
  while [[ $GUESS -ne $RAND_NUM ]]
  do
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]];
    then
      echo "That is not an integer, guess again:"
    else
      ((GUESSES++))

      if (( GUESS < RAND_NUM ));
      then
        echo "It's higher than that, guess again:"
      elif (( GUESS > RAND_NUM ));
      then
        echo "It's lower than that, guess again:"
      else
        SET_GAMES_PLAYED=$($PSQL "UPDATE user_data SET games_played = games_played + 1 WHERE username = '$USERNAME'")
        BEST_GAME=$($PSQL "SELECT best_game FROM user_data WHERE username = '$USERNAME'")
        if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]];
        then
          SET_BEST_GAME=$($PSQL "UPDATE user_data SET best_game = $GUESSES WHERE username = '$USERNAME'")
        fi
        echo "You guessed it in $GUESSES tries. The secret number was $RAND_NUM. Nice job!"
      fi
    fi
  done
}
MAIN_MENU