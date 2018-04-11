class User < ApplicationRecord
  has_many :created_games, :class_name => 'Game', foreign_key: "owner_id" 
  has_many :joined_games, :class_name => 'Game',  foreign_key: "opponent_id"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
