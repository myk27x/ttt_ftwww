class TTTGame

  def initialize
    @cells = [0,1,2,3,4,5,6,7,8]

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

  def set_player
    if body[:player_X] == nil
      body[:player_X] = playername
    elsif body[:player_O] == nil
      body[:player_O] = playername
    else
      puts "already full"
    end
  end
end


# Request:
# {
#   "player_X_name": "String containing the name of player X",
#   "player_O_name": "String containing the name of player O"
# }
# Response:
# Status code: 201
# Body:
# { "status": "ok",
#   "board": { "state": "playing",
#   "positions": { "0": " ",
#                  "1": " ",
#                  "2": " ",
#                  "3": " ",
#                  "4": " ",
#                  "5": " ",
#                  "6": " ",
#                  "7": " ",
#                  "8": " "
#                }
#          }
# }
# require 'sinatra'
require 'webrick'
require 'json'

JSON_FILE = File.dirname(__FILE__) + "/players.json"

class Game < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    TTTGame.new
    body = JSON.parse(File.read("players.json"))
      if body["player_X"] == 0
        body["player_X"] = "#{request.query["playername"]}"
      elsif body["player_O"] == 0
        body["player_O"] = "#{request.query["playername"]}"
      else
##TODO send diff response??? TODO###
        puts "already full"
      end
    File.write(JSON_FILE, body.to_json)

    board = JSON.parse(File.read("board.json"))
    puts board
    response.status = 201
    response.body = board.to_json
  end
end

server = WEBrick::HTTPServer.new(Port:3027)
server.mount "/", Game

trap("INT") { server.shutdown }

server.start

  # Creates a new game with a blank board.
  # take player names, assign them to X/O

  # @people  = File.exist?("people.txt") ? File.readlines("people.txt") : []
  # result =  (condition)              ?      if true                 : if false

  # return body hash of hash of hash
  # body = board


# Makes a move for a specific player
# post "/move" do
# end
