class Piece < ApplicationRecord


  belongs_to :game

	def color
    return 'white' if is_white == true
    'black'
  end

  def render
  	"#{color}-#{type.downcase}.png"
	end

  def check?(is_white)
    super
  end

#Updated move_to in a cleaner way. But same idea that you created.
  def move_to!(new_x, new_y)
    transaction do
      raise ArgumentError, "#{type} has not moved." unless real_move?(new_x, new_y)
      occupying_piece = game.get_piece_at_coor(new_x, new_y)
      raise ArgumentError, 'That is an invalid move. Cannot capture your own piece.' if same_color?(occupying_piece)
      capture_piece!(occupying_piece) if square_occupied?(new_x, new_y)
      update(x_position: new_x, y_position: new_y)
    end
  end

  def move_leaves_king_in_check?(new_x, new_y)
    result = false
    self.transaction do
      self.move_to!(to_x, to_y)
      if check?(self.color)
        result = true
        raise ArgumentError, 'That move leaves you in check!'
      end
    end
    return result
  end


  def same_color?(occupying_piece)
    occupying_piece.present? && occupying_piece.color == color
  end

  def square_occupied?(new_x, new_y)
    piece = game.pieces.find_by(x_position: new_x, y_position: new_y)
    return false if piece.nil?
    true
  end

  def off_board?(new_x, new_y)
      new_x < 1 || new_x > 8 || new_y < 1 || new_y > 8
  end

  def capture_piece!(captured_piece)
    captured_piece.update(x_position: nil, y_position: nil)
  end

  def real_move?(new_x, new_y)
    @piece = game.get_piece_at_coor(new_x, new_y)
    return true if @piece.nil?
    return false if @piece.id == id
    true
  end

  def count_moves
    game.update(move_number: game.move_number + 1)
    update(game_move_number: game.move_number, piece_move_number: piece_move_number + 1)
    update(has_moved: true)
  end


end
