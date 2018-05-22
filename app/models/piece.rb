class Piece < ApplicationRecord
  belongs_to :game

  def color
    return 'white' if is_white == true
    'black'
  end

  def render
    "#{color}-#{type.downcase}.png"
  end

  def is_black
    !is_white
  end

  # Updated move_to in a cleaner way. But same idea that you created.
  def move_to!(new_x, new_y)
    transaction do
      raise ArgumentError, "#{type} has not moved." unless real_move?(new_x, new_y)
      occupying_piece = game.get_piece_at_coor(new_x, new_y)
      raise ArgumentError, 'That is an invalid move. Cannot capture your own piece.' if same_color?(occupying_piece)
      capture_piece!(occupying_piece) if square_occupied?(new_x, new_y)
      capture_piece!(game.vulnerable_to_en_passant) if respond_to?(:can_attack_en_passant?) && can_attack_en_passant?(new_x, new_y)
      if respond_to?(:vulnerable_to_en_passant?) && vulnerable_to_en_passant?
        game.update(pawn_vulnerable_to_en_passant_piece: self)
      else
        game.update(pawn_vulnerable_to_en_passant_piece: nil)
      end
      update(x_position: new_x, y_position: new_y)
    end
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
    puts "captured_piece!"
    puts captured_piece
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
    update(piece_moved: true)
  end

  def get_piece_at_coor(x_pos, y_pos)
    game.get_piece_at_coor(x_pos, y_pos)
  end

  # CHECKMATE method
  # determine if a state of checkmate has occurred
  def checkmate?(color)
    checked_king = pieces.find_by(type: 'King', color: color)

    # make sure color is in check and get @piece_causing_check
    return false unless check?(color)

    # see if another piece can capture checking piece
    return false if @piece_causing_check.can_be_captured?

    # see if king can get himself out of check
    return false if checked_king.can_move_out_of_check?

    true
  end

  # determines if color is in check
  def check?(color)
    king = pieces.find_by(type: 'King', color: color)
    opponents = pieces_remaining(!color)
    opponents.each do |piece|
      if piece.valid_move?(king.x_position, king.y_position)
        @piece_causing_check = piece
        return true
      end
    end
    false
  end

  # method to determine if a piece can be captured.
  # called to determine checkmate
  def can_be_captured?
    opponents = game.pieces_remaining(!color)
    opponents.each do |opponent|
      # for each opponent, see if the checking piece can be captured
      return true if opponent.valid_move?(x_position, y_position)
    end
    false
  end


  # END CHECKMATE method

  def is_vertically_obstructed?(_new_x, new_y)
    x1 = x_position
    y1 = y_position
    if y1 < new_y
      small_y = y1
      big_y = new_y
    else
      small_y = new_y
      big_y = y1
    end
    i = small_y + 1

    while i < big_y
      if get_piece_at_coor(x1, i).nil?
        i += 1
      else
        return false
      end
    end
    true
  end

  def is_horizontally_obstructed?(new_x, _new_y)
    x1 = x_position
    y1 = y_position
    if x1 < new_x
      small_x = x1
      big_x = new_x
    else
      small_x = new_x
      big_x = x1
    end

    i = small_x + 1

    while i < big_x
      if get_piece_at_coor(i, y1).nil?
        i += 1
      else
        return false
      end
    end
    true
  end


  def is_diagonally_obstructed(new_x, new_y)
    x1 = x_position
    y1 = y_position
    raise 'Invalid move' if (x1 - new_x).abs != (y1 - new_y).abs

    if (x1 < new_x) && (y1 < new_y)

      x = x1 + 1
      y = y1 + 1
      while x < new_x
        if get_piece_at_coor(x, y).nil?
          x += 1
          y += 1
        else
          return false
        end
      end
      return true
    end


    if (x1 < new_x) && (y1 > new_y)

      x = x1 + 1
      y = y1 - 1
      while x < new_x
        if get_piece_at_coor(x, y).nil?
          x += 1
          y -= 1
        else
          return false
        end
      end
      return true
    end


    if (x1 > new_x) && (y1 < new_y)

      x = x1 - 1
      y = y1 + 1
      while x > new_x
        if get_piece_at_coor(x, y).nil?
          x -= 1
          y += 1
        else
          return false
        end
      end
      return true
    end


    if (x1 > new_x) && (y1 > new_y)

      x = x1 - 1
      y = y1 - 1
      while x > new_x
        if get_piece_at_coor(x, y).nil?
          x -= 1
          y -= 1
        else
          return false
        end
      end
      return true
    end
  end

  def is_obstructed?(new_x, new_y)
    x1 = x_position
    y1 = y_position
    if x1 === new_x
      is_vertically_obstructed?(new_x, new_y)
    elsif y1 === new_y
      is_horizontally_obstructed?(new_x, new_y)
    else
      is_diagonally_obstructed?(new_x, new_y)
    end
  end
end
