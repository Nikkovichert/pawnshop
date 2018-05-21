# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180521023102) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bishops", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.string   "name"
    t.integer  "black_player_id"
    t.integer  "white_player_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "player_win"
    t.integer  "player_lose"
    t.boolean  "white_player_turn",                default: true
    t.integer  "state",                            default: 0,    null: false
    t.integer  "move_number",                      default: 0,    null: false
    t.integer  "pawn_vulnerable_to_en_passant_id"
    t.index ["black_player_id"], name: "index_games_on_black_player_id", using: :btree
    t.index ["pawn_vulnerable_to_en_passant_id"], name: "index_games_on_pawn_vulnerable_to_en_passant_id", using: :btree
    t.index ["white_player_id"], name: "index_games_on_white_player_id", using: :btree
  end

  create_table "kings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "knights", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pawns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pieces", force: :cascade do |t|
    t.string   "type"
    t.integer  "x_position"
    t.integer  "y_position"
    t.string   "color"
    t.string   "image"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "game_id"
    t.boolean  "is_white"
    t.boolean  "piece_moved",       default: false
    t.integer  "game_move_number",  default: 0,     null: false
    t.integer  "piece_move_number", default: 0,     null: false
    t.index ["game_id"], name: "index_pieces_on_game_id", using: :btree
  end

  create_table "queens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.integer  "id_for_user"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "games_played"
    t.integer  "player_record"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "games", "pieces", column: "pawn_vulnerable_to_en_passant_id"
end
