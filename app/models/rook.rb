class Rook < Piece
  def valid_move?(new_x, new_y)
    own_piece_at_destination?(new_x, new_y)
    !is_obstructed?(new_x, new_y)
    (y_position == new_y) && (x_position != new_x) || (x_position == new_x) && (y_position !=new_y)
    !off_board?(new_x new_y)
  end
end
