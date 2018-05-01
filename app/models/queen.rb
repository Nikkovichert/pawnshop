class Queen < Piece

    def valid_move?(new_x, new_y)
      x1 = self.x_position
      y1 = self.y_position
      own_piece_at_destination?(new_x, new_y)
      !is_obstructed?(new_x, new_y)
      !off_board?(new_x new_y)
      ((x_position != new_x && y_position != new_y) && ((x1 + new_x).abs === (y1 + new_y).abs)) ||
      ((y_position == new_y) && (x_position != new_x)) || ((x_position == new_x) && (y_position !=new_y))
    end

end
