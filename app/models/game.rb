class Game < ApplicationRecord
  belongs_to :white_player, class_name: 'User'
  belongs_to :black_player, class_name: 'User', optional: true

  has_many :pieces, dependent: :destroy
  has_one :pawn_vulnerable_to_en_passant_piece, class_name: 'Piece'

  scope :available, -> { where('white_player_id IS NULL OR black_player_id IS NULL') }
  scope :ongoing, -> { where.not('white_player_id IS NULL OR black_player_id IS NULL') }

  validates :name, presence: true

  def populate_board!
    1.upto(8).each do |i|
      Pawn.create(game_id: id, is_white: true, x_position: i, y_position: 2)
    end

    Rook.create(game_id: id, is_white: true, x_position: 1, y_position: 1)
    Rook.create(game_id: id, is_white: true, x_position: 8, y_position: 1)

    Knight.create(game_id: id, is_white: true,  x_position: 2, y_position: 1)
    Knight.create(game_id: id, is_white: true,  x_position: 7, y_position: 1)

    Bishop.create(game_id: id, is_white: true, x_position: 3, y_position: 1)
    Bishop.create(game_id: id, is_white: true, x_position: 6, y_position: 1)

    King.create(game_id: id, is_white: true, x_position: 5, y_position: 1)
    Queen.create(game_id: id, is_white: true, x_position: 4, y_position: 1)

    # Black Player#
    1.upto(8).each do |i|
      Pawn.create(game_id: id, is_white: false, x_position: i, y_position: 7)
    end

    Rook.create(game_id: id, is_white: false, x_position: 1, y_position: 8)
    Rook.create(game_id: id, is_white: false, x_position: 8, y_position: 8)

    Knight.create(game_id: id, is_white: false, x_position: 2, y_position: 8)
    Knight.create(game_id: id, is_white: false, x_position: 7, y_position: 8)

    Bishop.create(game_id: id, is_white: false, x_position: 3, y_position: 8)
    Bishop.create(game_id: id, is_white: false, x_position: 6, y_position: 8)

    King.create(game_id: id, is_white: false, x_position: 5, y_position: 8)
    Queen.create(game_id: id, is_white: false, x_position: 4, y_position: 8)
  end

  # Checkmate Starts

  # The player whose turn it is to move is not in check but has no legal move

  def checkmate?(color)
    return false unless in_check?(color)
    return false if capture_opponent_causing_check?(color)
    return false if i_can_move_out_of_check?(color)
    return false if i_can_avoid_check?(color)
    true
  end

  # determines if color is in check
  def in_check?(color)
    @enemies_in_check = []
    king = find_king(color)
    if king
      opponents = opponents_pieces(color)
      opponents.each do |piece|
        @enemies_in_check << piece if piece.valid_move?(king.x_position, king.y_position) == true
      end
    end
    @enemies_in_check.any?
  end

  def capture_opponent_causing_check?(color)
    friendlies = my_pieces(color)
    not_capture = []
    friendlies.each do |friend|
      @enemies_in_check.each do |enemy|
        not_capture << friend if friend.valid_move?(enemy.x_position, enemy.y_position) == true
      end
    end
    return true if not_capture.any?
    false
  end

  def i_can_move_out_of_check?(color)
    king = find_king(color)
    x_start = king.x_position
    y_start = king.y_position
    state = false
    ((king.x_position - 1)..(king.x_position + 1)).each do |x|
      ((king.y_position - 1)..(king.y_position + 1)).each do |y|
        king.update(x_position: x, y_position: y) if king.valid_move?(x, y)
        state = true unless in_check?(color)
        king.update(x_position: x_start, y_position: y_start)
      end
    end
    state
  end

  def i_can_avoid_check?(color)
    available_moves = []
    my_pieces(color).each do |piece|
      1.upto(8) do |x|
        1.upto(8) do |y|
          if piece.valid_move?(x, y) && !piece.move_causes_check?(x, y)
            available_moves << [x, y]
          end
        end
      end
    end

    available_moves.any?
  end

  # Checkmate Ends

  def render_piece(x_pos, y_pos)
    piece = get_piece_at_coor(x_pos, y_pos)
    piece.render if piece.present?
  end

  def get_piece_at_coor(x_pos, y_pos)
    pieces.find_by(x_position: x_pos, y_position: y_pos)
  end


  def forfeit(current_user)
    if current_user.id == white_player_id
      update!(player_win: black_player_id, player_lose: white_player_id)
    elsif current_user.id == black_player_id
      update!(player_win: white_player_id, player_lose: black_player_id)
    end
  end

  # logic relating to state
  IN_PROGRESS = 0
  FORFEIT = 1
  CHECKMATE = 2
  STALEMATE = 3
  AGREED_DRAW = 4
end
