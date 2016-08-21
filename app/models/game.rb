class Game < ApplicationRecord
  belongs_to :board
  belongs_to :letter_set
  belongs_to :words_list
  belongs_to :starter, class_name: "User"
  has_many :gamers
  has_many :turns
  
  
end
