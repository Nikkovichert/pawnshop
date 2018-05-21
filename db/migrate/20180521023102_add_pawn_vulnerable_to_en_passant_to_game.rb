class AddPawnVulnerableToEnPassantToGame < ActiveRecord::Migration[5.0]
  def change
    add_reference :games, :pawn_vulnerable_to_en_passant, foreign_key: { to_table: :pieces }
  end
end
