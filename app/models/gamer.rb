class Gamer < ApplicationRecord
  include AASM

  belongs_to :game
  belongs_to :user
  has_many :turns
  
  def play_state
    if game.in_play?
      if in_turn?
        aasm.human_state
      else
        Turn.where(game_id: game_id, user_id: user.id).last(2)[0].aasm.human_state
      end
    else
      aasm.human_state
    end
  end
  
  private #============================================================
  
  before_create do
    self.state = 'selected'
    self.score = 0
  end
  
  # State Machine
  # aasm.attribute_name :state
  aasm column: :state do
  # aasm do
    state :selected, initial: true
    state :invited
    state :accepted
    state :rejected
    state :expired
    state :waiting
    state :in_turn
    
    event :invite do
      transitions from: :selected, to: :invited
    end
    event :accept, after: :create_turn do
      transitions from: :invited, to: :accepted
    end
    event :reject do
      transitions from: :invited, to: :rejected
    end
    event :wait_too_long do
      transitions from: :invited, to: :expired
    end
    event :game_started do
      transitions from: :accepted, to: :waiting
    end
    event :gets_turn do
      transitions from: :waiting, to: :in_turn
    end
    event :turned do
      transitions from: :in_turn, to: :waiting
    end
  end
  
  def create_turn
    Turn.create(
      user_id: user_id, 
      game_id: game_id,
      gamer_id: id
    )
  end
end
