JSON_FILE_PLAYERS = File.dirname(__FILE__) + "/players.json"
JSON_FILE_BOARD = File.dirname(__FILE__) + "/board.json"

class TTTGame

  def initialize
    @cells = [" "," "," "," "," "," "," "," "," "]

    @board = { "current_player": "choosing_player",
      "status": "status",
      "board": { "state": "state",
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
    if @board[:"current_player"] == @players[:"player_X"]
      choosing_player = @players[:"player_O"]
    elsif @board[:"current_player"] == @players[:"player_O"]
      choosing_player = @players[:"player_X"]
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
          cell == " "
          state = "tie"
        end
      else
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
          state = "tie"
        end
      else
        state = "playing"
      end
  #   end
  # end

  def update_move(position, player_symbol)
    # check if move is valid
    @cells.select do |cell|
      if @cells[position] == " "
        # post move to cells
        @cells[position] = player_symbol
      else
        cell
      end
    end
  end

  def update_status(position, player_symbol)
    if
      @cells[position] == player_symbol
      status = "ok"
    else
      status = "invalid"
    end
  end

end

require 'sinatra'
set :port, 3027
require 'sinatra/reloader' if development?
require 'json'

configure do
  set :board, TTTGame.new
end

post '/game' do
  @game = TTTGame.new
  settings.board = @game
  ##TODO should players be class instances??? TODO##
  @players = JSON.parse(File.read("players.json"))
  if @players["player_X"] == 0
    @players["player_X"] = "#{params["playername"]}"
  elsif @players["player_O"] == 0
    @players["player_O"] = "#{params["playername"]}"
  else
    ##TODO send diff response??? TODO###
    puts "already full"
  end
  ##TODO what tells the game to start (go to /move)? TODO###

  File.write(JSON_FILE_PLAYERS, @players.to_json)

  choosing_player = @players["player_X"]
  status = "ok"
  state = "playing"
  @board = @game.update_board_after_moves(choosing_player, status, state)

  response.status = 201
  response.body = @board.to_json
end

post '/move' do
  @game = settings.board

  player_symbol = "#{params["player"]}"
  position = "#{params["position"]}"
  position = position.to_i

  #update variables for response body
  @cells = @game.update_move(position, player_symbol)
  status = @game.update_status(position, player_symbol)

  if
    status == "ok"
    # choosing_player = @game.update_player
    choosing_player = "Kevin"
    state = @game.update_state_if_winner
    @board = @game.update_board_after_moves(choosing_player, status, state)
    response.status = 200
    response.body = @board.to_json
  else
    @board = @game.update_board_after_moves(choosing_player, status, state)
    response.status =  409
    response.body = @board.to_json
  end

end
