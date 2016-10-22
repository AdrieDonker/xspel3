class Game < ApplicationRecord
  include AASM
  
  belongs_to :board
  belongs_to :letter_set
  belongs_to :words_list
  belongs_to :owner, class_name: "User"  
  # belongs_to :starter, class_name: "User"
  has_many :gamers #, -> { order(:sequence_nbr) }
  has_many :users, through: :gamers
  has_many :turns
  
  serialize :laid_letters   # Array.new(15){Array.new(15)}[[<letter>, <punten>], [<letter>, <punten>], ]
  serialize :stock_letters  # Array nog beschikbare letters [[<letter>, <punten>], [<letter>, <punten>], ]
  serialize :words_list_groups # Array: [ [wl_groep, wl_id], ...]
  serialize :extra_words_lists # Array: [ [wl_groep, wl_id], ...]
  
  # validates :name, presence: true, uniqueness: true
  validate :minimum_2_players
 
  # Validations
  def minimum_2_players
    if self.user_ids.size < 2
      errors.add(:gamers, :minimum_2_players)
    end
  end
  
  # Return array with gamer-names  
  def gamer_names
    gn = []
    gamers.sort_by(&:sequence_nbr).each do |g|
    # self.users.each do |g|
      gn << g.user.name
    end
    return gn
  end
  
  # Create turn for gamer
  def create_turn(gamer)
    # if self.game.turns.count == 0
      Turn.create( 
        user_id: gamer.id, 
        game_id: id
      )
    # end
  end

  # Add old_letters up to 7 letters
  def adjust_letters(letters_old)
    if letters_old.size < 7 
      letters_old + give_letters(7 - letters_old.size)
    else
      return letters_old
    end
  end

  # Return (max 7) random letters from stock
  def give_letters(nbr_of)
    new_stock = []
    count_letters = []

    stock_letters.shuffle.each do |v|
      if count_letters.size < nbr_of
        count_letters << v
      else
        new_stock << v
      end
    end
    self.stock_letters = new_stock
    self.save
    return count_letters
  end
  
  # Return last completed turn
  def last_played
    lp = turns.last(2)[0]
    
    # not yet played
    if lp.wait?
      I18n.t :waits_for_play
    
    # played
    elsif lp.played?
      wrds = lp.words.collect{|w| w[0]}.join(' ')
      lp.user.name + ' ' + (I18n.t :played) + ' [' + wrds + ']: ' + 
        lp.score.to_s + ' ' + (I18n.t :points)
    
    #other
    else
      lp.user.name + ': ' + lp.aasm.human_state
    end
  end

  # Check on invite
  def waits_for_you(user)
    users.include?(user) and gamers.find_by(user_id: user.id).state == 'invited'
  end

  # Up to the next gamer/turn
  def goto_next(last_turn) 

    # gamer had his turn
    last_turn.gamer.score += last_turn.score
    last_turn.gamer.turned!
    
    # swapped, then swap letters back to stock
    if last_turn.swapped?
      self.stock_letters += (last_turn.start_letters - last_turn.end_letters)
      save
    end
    
    # set next turn/gamer to play
    Turn.find_by(
      game_id: id, 
      sequence_nbr: last_turn.sequence_nbr + 1
    ).get_turn!

    # create new turn for gamer en return it
    Turn.create(
      game_id: id, 
      user_id: last_turn.user.id,
      gamer_id: last_turn.gamer.id,
      start_letters: adjust_letters(last_turn.end_letters),
      sequence_nbr: turns.order(:sequence_nbr).last.sequence_nbr + 1
    )
  end
  
  # Save laid_letters in the board
  def letters_to_board(letters)
    logger.info 'ltrs= ' + letters.to_s
    logger.info 'll voor: ' + laid_letters.to_s
    letters.each do |ll|
      self.laid_letters[ll[0]][ll[1]] = [ll[2], ll[3]]
    end
    logger.info 'll na: ' + laid_letters.to_s
    save
  end
    
  # Available letters from lettersets
  def letters
    ltrs = []
    letter_set.letter_amount_points.each do |k, v|
      ltrs << k.to_s unless k == :""
    end
    return ltrs.sort
  end
  
  # private #-----------------------------------------------------------------------------------

  # Callbacks
  before_create do
    self.laid_letters = Array.new(15){Array.new(15)}
    self.stock_letters = letter_set.all_letters_points  #.shuffle
    self.words_list_groups = set_words_list_groups
    self.invite_time = 10.hours
    self.play_time = 10.hours
  end

  before_save do
    if startable?
      self.stock_letters = letter_set.all_letters_points  #.shuffle
      self.words_list_groups = set_words_list_groups
    end
  end
  
  def set_words_list_groups
    # Read wordslists
    wl_groups = []
    WordsList.where( {:name => words_list.name}, :order => "group").each do |wl|
      wl_groups << [wl.group, wl.id] if wl.id != words_list.id
    end
    return wl_groups
  end
  
  # # State Machine
  aasm column: :state do
    state :startable, initial: true
    state :playable
    state :pre_abort
    state :in_play
    state :ended
    state :aborted
    
    event :start_now do
      transitions from: :startable, to: :playable, after: :create_base
    end
    event :play_now do
      transitions from: :playable, to: :in_play, 
        guard: :invites_completed, after: :init_play
    end
    event :incompletion do
      transitions from: :playable, to: :pre_abort, guard: :too_less_players
    end
    event :played_out do
      transitions from: :in_play, to: :ended
    end
    event :pre_ended do
      transitions from: :in_play, to: :abort
    end

  end
  
  # create first turns and player sequence
  def create_base

    # create turns and send invites
    seq = 0
    gamers.shuffle.each do |g|
      seq += 1
      g.invite!
      g.update(sequence_nbr: seq)
    end
    self.invited_at = Time.now
    save
  end

  # invites completed, resequence the players/turns, delete non-acceptants turns
  def init_play
    
    seq = 0
    # gamers.sort_by(&:sequence_nbr).each do |g|
    gamers.order(:sequence_nbr).each do |g|
      turn = Turn.find_by(game_id: id, user_id: g.user_id)
      if g.accepted?
        seq += 1
        g.sequence_nbr = seq
        g.game_started
        g.save
        turn.sequence_nbr = seq
        turn.get_turn if seq == 1 #first player
        turn.save   
      else
        g.sequence_nbr = 0
        g.save
        turn.delete
      end
    end
  end
    
  def invites_completed
    if inviting_ended
      if enough_gamers
        true
      
      # not enough players, quit
      else
        incompletion!  # pre_abort
        errors.add(:gamers, :too_less_players)
        # errors[:base] << (I18n.t 'too_less_players') #"Er zijn minder dan 2 geaccepteerde uitnodigingen!"
        false
      end
    else
      errors[:base] << "Er zijn nog lopende uitnodigingen!"
      false
    end
  end

  def too_less_players
    if inviting_ended and not enough_gamers
      incompletion  # pre_abort
      save
      # errors.add(:gamers, :too_less_gamers)
      errors[:base] << :too_less_gamers
      true
    else
      false
    end
  end
    
  def inviting_ended
    invite_time_expired? or running_invites == 0
  end

  def running_invites
    gamers.where(state: 'invited').count
  end

  def invite_time_expired?
    Time.now - invited_at >= invite_time # seconds
  end
    
  def enough_gamers
    gamers.where(state: 'accepted').count > 1
  end

end
