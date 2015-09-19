JSON_FILE_PLAYERS = File.dirname(__FILE__) + "/players.json"
JSON_FILE_BOARD = File.dirname(__FILE__) + "/board.json"

class TTTGame

  def initialize
    @cells = [" "," "," "," "," "," "," "," "," "]

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

  def update_board_after_moves(choosing_player, status, state)
    @board = { "current_player": choosing_player,
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
  end

  def update_player
    if @board[:"current_player"] == players[:"player_X"]
      choosing_player = players[:"player_O"]
    elsif @board["current_player"] == players[:"player_O"]
      choosing_player = players[:"player_X"]
    end
  end

  def update_state_if_winner
    @win2.each do |inner|
      case
      when
        inner == [:X,:X,:X]
        state = "Player X wins!"
        # player X wins - player X has won #NOTE should this include name???
      when
        inner == [:O,:O,:O]
        state = "Player O wins!"
        # player Y wins - player Y has won #NOTE should this include name???
      when
        @cells.all? do |cell|
          cell != " "
          status = "tie"
        end
      else
        state = "playing"
      end
    end
  end

end

require 'sinatra'
set :port, 3027
require "sinatra/reloader" if development?

post '/game' do
  @game = TTTGame.new
  ##TODO should players be class instances??? TODO##
  players = JSON.parse(File.read("players.json"))
  if players["player_X"] == 0
    players["player_X"] = "#{params["playername"]}"
  elsif players["player_O"] == 0
    players["player_O"] = "#{params["playername"]}"
  else
    ##TODO send diff response??? TODO###
    puts "already full"
  end
  ##TODO what tells the game to start (go to /move)? TODO###

  File.write(JSON_FILE_PLAYERS, players.to_json)

  choosing_player = players["player_X"]
  status = "ok"
  state = "playing"
  @game.update_board_after_moves(choosing_player, status, state)

  response.status = 201
  response.body = @board.to_json
end

post '/move' do
  # receive into variable
  # {
  #   "player": "X",
  #   "position": "0"
  # }
  player_symbol = "#{params["player"]}"
  position = "#{params["position"].to_i}"

  # check if move is valid
  @cells.map do |cell|
    if cell != "X" || "O"

      # post move to cells
      @cells[position] = player_symbol

      #update variables for response body
      choosing_player = @game.update_player
      status = "ok"
      state = @game.update_state_if_winner
      @game.update_board_after_moves(choosing_player, status, state)

      #return updated gameboard
      response.status = 200
      response.body = @board.to_json

    else
      status = "invalid"
      @game.update_board_after_moves(choosing_player, status, state)

      response.status =  409
      response.body =  @board.to_json
    end

end
