class Turn < ApplicationRecord
  belongs_to :user
  belongs_to :game
  
  serialize :start_letters
  serialize :end_letters
  
  before_create do 
    self.state = 'wait'
    self.start_letters = game.give_letters(7)
  end

 
end
