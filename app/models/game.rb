class Game < ApplicationRecord
  belongs_to :board
  belongs_to :letter_set
  belongs_to :words_list
end
