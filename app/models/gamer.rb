class Gamer < ApplicationRecord
  belongs_to :game
  belongs_to :user
  
  before_create do
    self.state = 'selected'
  end
end
