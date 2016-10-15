class Turn < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :game
  belongs_to :gamer
  
  serialize :start_letters
  serialize :end_letters
  
  private #---------------------------------------------
  
  before_create do 
    self.state = 'wait'
    self.start_letters = game.give_letters(7) if start_letters.nil?
  end

  # State Machine
  aasm column: :state do
    state :wait, initial: true
    state :play
    state :passed
    state :swapped
    state :played
    state :ended
    
    event :get_turn, after: :start_turn do
      transitions from: :wait, to: :play
    end
    event :passing do
      transitions from: :play, to: :passed
    end
    event :swapping do
      transitions from: :play, to: :swapped
    end
    event :playing do
      transitions from: :play, to: :played
    end
    event :expiring do
      transitions from: :play, to: :ended
    end

  end
  
  def start_turn
    self.started = Time.now
    save
    gamer.gets_turn!
  end
 
end
