require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'populate_board!' do
    it 'should have correct number of pieces' do
      game = Game.create(white_player_id: 0, black_player_id: 1)
      game.populate_board!
      expect(game.pieces.count).to eq 32
    end
  end

  describe 'in_check method' do
    context 'Rook pieces' do
      it 'True when opposing piece can capture king' do
        board = create_game_with_no_pieces

        black_rook = Rook.create(x_position: 0, y_position: 7, game_id: id, is_white: true, type: 'Rook')
        white_king = King.create(x_position: 0, y_position: 0, game_id: id, is_white: true, type: 'King')

        board.pieces << white_king
        board.pieces << black_rook

        expect(id.in_check?('WHITE')).to eq(true)
      end
    end
  end

  describe 'capture_opponent_causing_check?' do
  it 'True if white king enemies causing check are capturable' do
    board = create_game_with_no_pieces

    king = King.new(x_position: 4, y_position: 4, is_white: true, game_id: id, type: 'King')
    queen = Queen.new(x_position: 3, y_position: 4, is_white: true, game_id: id, type: 'Queen')

    board.pieces << queen
    board.pieces << king

    expect(board.in_check?('WHITE')).to eq true
    expect(board.capture_opponent_causing_check?('WHITE')).to eq true
  end
end

  describe 'can_i_move_out_of_check?' do
    it 'True if white king can move out of check' do
      board = create_game_with_no_pieces

      king = King.new(x_position: 4, y_position: 4, is_white: true, game_id: id, type: 'King')
      queen = Queen.new(x_position: 5, y_position: 4, is_white: true, game_id: id, type: 'Queen')

      board.pieces << queen
      board.pieces << king

      expect(board.in_check?('WHITE')).to eq true
      expect(board.send(:i_can_move_out_of_check?, 'WHITE')).to eq true
    end
  end
end
