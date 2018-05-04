class PiecesController < ApplicationController
  
  def show
    @piece = Piece.find(params[:id])
    @game = @piece.game
  end
  
  def update
    piece_to_move = Piece.find(params[:id])
    @game = piece_to_move.game
    piece_to_move.move_to!(:x_position, :y_position) 
    @game.update(white_player_turn: !@game.white_player_turn)
    redirect_to game_path(@game)
  end

end 






