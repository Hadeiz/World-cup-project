#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

INSERT_TEAMS_STRING="insert into teams(name) values"
cat games.csv |
{
  while IFS="," read BAR BAR WINNER OPPONENT BAR BAR
  do
    if [[ $WINNER != winner ]]
    then
      if [[ ! $INSERT_TEAMS_STRING =~ "$WINNER" ]]
      then
        if [[ $INSERT_TEAMS_STRING =~ .*values$ ]]
        then
          INSERT_TEAMS_STRING+=" ('$WINNER')"
        else
          INSERT_TEAMS_STRING+=", ('$WINNER')"
        fi
      elif [[ ! $INSERT_TEAMS_STRING =~ $OPPONENT ]]
      then
        if [[ $INSERT_TEAMS_STRING =~ .*values$ ]]
        then
          INSERT_TEAMS_STRING+=" ('$OPPONENT')"
        else
          INSERT_TEAMS_STRING+=", ('$OPPONENT')"
        fi
      fi
    fi
  done
  INSERT_TEAMS_RESULT=$($PSQL "$INSERT_TEAMS_STRING")
}

INSERT_GAMES_STRING="insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values"
cat games.csv |
{
  while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  do
  if [[ $YEAR != "year" ]]
  then
    WINNER_ID="$($PSQL "select team_id from teams where name = '$WINNER';")"
    OPPONENT_ID="$($PSQL "select team_id from teams where name = '$OPPONENT';")"
    if [[ $INSERT_GAMES_STRING =~ .*values$ ]]
      then
      INSERT_GAMES_STRING+=" ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"
      else
      INSERT_GAMES_STRING+=", ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"
    fi
  fi
  done
  GAMES_INSERT_RESULT="$($PSQL "$INSERT_GAMES_STRING")"
}
