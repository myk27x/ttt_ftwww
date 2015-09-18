class TTTGame

  def initialize
    @cells = [0,1,2,3,4,5,6,7,8]

    @board = { "current_player": "choosing_player",
             "status": "ok",
             "board": { "state": "playing",
                        "positions": { "0": @cells[0],
                                       "1": @cells[1],
                                       "2": @cells[2],
                                       "3": @cells[3],
                                       "4": @cells[4],
                                       "5": @cells[5],
                                       "6": @cells[6],
                                       "7": @cells[7],
                                       "8": @cells[8]
                                     }
                      }
            }

    @win2 = [
      [0,1,2],
      [3,4,5],
      [6,7,8],
      [0,3,6],
      [1,4,7],
      [2,5,8],
      [0,4,8],
      [2,4,6]
    ]
  end
end

# require 'sinatra'
require 'webrick'
require 'json'

JSON_FILE = File.dirname(__FILE__) + "/players.json"

class Game < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    TTTGame.new

    ##TODO should players be class instances??? TODO##
    body = JSON.parse(File.read("players.json"))
      if body["player_X"] == 0
        body["player_X"] = "#{request.query["playername"]}"
      elsif body["player_O"] == 0
        body["player_O"] = "#{request.query["playername"]}"
      else

        ##TODO send diff response??? TODO###
        puts "already full"
      end
      ##TODO what tells the game to start (go to /move)? TODO###

    File.write(JSON_FILE, body.to_json)

    board = JSON.parse(File.read("board.json"))
    response.status = 201
    response.body = board.to_json
  end
end

class Move
  def do_POST(request, response)

    # Request:
    # {
    #   "player": "X",
    #   "position": "0"
    # }

    # If the move is invalid (the space is currently occupied)
    # Status code: 409
    #  {
    #    "status": "invalid",
    #    "reason": "Already an (X or O) at this space",
    #    "board": { "state": "playing", etc.
    ##TODO needs input variables from client TODO##

    @board = {
      "current_player": choosing_player,
      "status": status,
      "board": { "state": state,
                 "positions": { "0": @cells[0],
                                "1": @cells[1],
                                "2": @cells[2],
                                "3": @cells[3],
                                "4": @cells[4],
                                "5": @cells[5],
                                "6": @cells[6],
                                "7": @cells[7],
                                "8": @cells[8]
                              }
                }
  }


  ## TODO can this be used to modify board?
  ## TODO need return for invalid move
  def make_move
    @cells.map do |cell|
      if cell == @p1_choice
        @cells[@p1_choice] = :X
        return true
      end
    end
  end

## TODO modify for use on winner tally (incorporate with winner?)
  def tally
    @win2.each do |inner|
      inner.map! do |value|
        if(value == @p1_choice)
          value = :X
        elsif(value == @p2_choice)
          value = :O
        elsif(value == @ai_choice)
          value = :C
        else
          value
        end
      end
    end
  end

## TODO modify for use // need return for winner?
  def winner
    @win2.each do |inner|
      if inner == [:X,:X,:X]
        puts "#{@name1} wins!"
        play_again
      elsif inner == [:O,:O,:O]
        puts "#{@name2} wins!"
        play_again
      elsif inner == [:C,:C,:C]
        puts "Computer wins!"
        play_again
      end
    end
  end

# NOTE: need player name and position from URL
# Request:
# X player moves to position 0
# Request:
# {
#   "player": "X",
#   "position": "0"
# }
# If the move is valid (the space is currently unoccupied)
# Status code: 200
# Body:
#  {
#    "status": "ok",
#    "board": { "state": "playing",
#
# NOTE: The board should be updated with an X or an O depending on which player made the move.
# NOTE: The state should be updated with one of these values:

# playing - the game is ongoing
# tie - the game is a tie
# player X wins - player X has won
# player Y wins - player Y has won
#
  end
end


server = WEBrick::HTTPServer.new(Port:3027)
server.mount "/game", Game
server.mount "/move", Move

trap("INT") { server.shutdown }

server.start
