## WORKING FILE
body = { "state": "playing",
     "positions": { "0": " ",
                    "1": " ",
                    "2": " ",
                    "3": " ",
                    "4": " ",
                    "5": " ",
                    "6": " ",
                    "7": " ",
                    "8": " "
                  }
       }

position_choice = :"1"
player_symbol = "X"

hashes = body.each do |key, value|
  if key == :"positions"
    choices = value
    choices.select do |choice|
      if choice == position_choice
        choices[choice] = player_symbol
      end
    end
  end
end


p hashes

## API

This is a suggested API, you may find that something else works better for you. It may also not be entirely complete, you will likely need to add additional methods to complete the game.

POST /game

Behavior

Creates a new game with a blank board.

Request:

{
  "player_X_name": "String containing the name of player X",
  "player_O_name": "String containing the name of player O"
}
Response:

Status code: 201

Body:

{
 "status": "ok",
 "board": { "state": "playing",
            "positions": { "0": " ",
                           "1": " ",
                           "2": " ",
                           "3": " ",
                           "4": " ",
                           "5": " ",
                           "6": " ",
                           "7": " ",
                           "8": " "
                         }
         }
}
## POST /move

Behavior

Makes a move for a specific player

Request:

Examples

X player moves to position 0
Request:

{
  "player": "X",
  "position": "0"
}
Response:

{
 "status": "ok",
 "board": { "state": "playing",
            "positions": { "0": "X",
                           "1": " ",
                           "2": " ",
                           "3": " ",
                           "4": " ",
                           "5": " ",
                           "6": " ",
                           "7": " ",
                           "8": " "
                         }
         }
}
O player moves to position 4
Request:

 {
   "player": "O",
   "position": "4"
 }
Response:

 {
   "status": "ok",
   "board": { "state": "playing",
              "positions": { "0": "X",
                             "1": " ",
                             "2": " ",
                             "3": " ",
                             "4": "O",
                             "5": " ",
                             "6": " ",
                             "7": " ",
                             "8": " "
                           }
           }
 }
X player moves to position 3
Request:

{
  "player": "X",
  "position": "3"
}
Response:

   {
     "status": "ok",
     "board": { "state": "playing",
                "positions": { "0": "X",
                               "1": " ",
                               "2": " ",
                               "3": "X",
                               "4": "O",
                               "5": " ",
                               "6": " ",
                               "7": " ",
                               "8": " "
                             }
             }
   }
NOTE: The value for player is either an "X" or an "O".
NOTE: The value for "position" is a "0", "1", "2" , "3", "4", "5", "6", "7", or "8"
Response:

If the move is valid (the space is currently unoccupied)

Status code: 200

Body:

 {
   "status": "ok",
   "board": { "state": "playing",
              "positions": { "0": " ",
                             "1": " ",
                             "2": " ",
                             "3": " ",
                             "4": " ",
                             "5": " ",
                             "6": " ",
                             "7": " ",
                             "8": " "
                           }
           }
 }
NOTE: The board should be updated with an X or an O depending on which player made the move.
NOTE: The state should be updated with one of these values:
playing - the game is ongoing
tie - the game is a tie
player X wins - player X has won
player Y wins - player Y has won
If the move is invalid (the space is currently occupied)

Status code: 409

 {
   "status": "invalid",
   "reason": "Already an (X or O) at this space",
   "board": { "state": "playing",
              "positions": { "0": " ",
                             "1": " ",
                             "2": " ",
                             "3": " ",
                             "4": " ",
                             "5": " ",
                             "6": " ",
                             "7": " ",
                             "8": " "
                           }
           }
 }
NOTE: The reason should say either "Already an X at this space" or "Already an O at this space"
NOTE: The board should be the previous board state without the requested move
Resources

Test your API responses locally: (if running Sinatra)

brew install httpie

http http://localhost:4567/game player_X_name=Gavin player_O_name=Jason --form
