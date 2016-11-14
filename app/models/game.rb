class Game < ApplicationRecord
  include AASM
  
  attr_accessor :play_time_days, :play_time_hours, :play_time_minutes, :js_time
  
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
  validate :minimum_1_player, :minimum_play_time
 
  # Validations
  def minimum_1_player
    if self.user_ids.size < 1
      errors.add(:gamers, :minimum_1_player)
    end
  end
 
  def minimum_play_time
    if @time_days and @time_hours and @time_minutes
      if calc_play_seconds < 1.minute
        logger.info 'minimum_play_time ERROR'
        errors.add(:play_time, :min_1_minute)
      end
    end
  end
 
  # virtual attributes
  def play_time_days
    self.play_time ||= 0
    play_time / 86400
  end
  def play_time_days=(days)
    @time_days = days.to_i
  end
  def play_time_hours
    (play_time - play_time_days * 86400) / 3600
  end
  def play_time_hours=(hours)
    @time_hours = hours.to_i
  end
  def play_time_minutes
    (play_time - play_time_days * 86400 - play_time_hours * 3600) / 60
  end
  def play_time_minutes=(minutes)
    @time_minutes = minutes.to_i
  end
  
  # Check if playing can start
  def check_play_now(js_time)
    if may_play_now?
      self.started_at = Time.at(js_time / 1000)    # take from browser
      play_now!
      true
    else
      false
    end
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
  
  # Check on invite
  def waits_for_you(user)
    users.include?(user) and gamers.find_by(user_id: user.id).state == 'invited'
  end

  # Up to the next gamer/turn
  def goto_next(last_turn) 
    
    logger.info '@@@@@@@@@@ game goto_next:'
    # byebug
    # gamer had his turn
    last_turn.gamer.score += last_turn.score
    last_turn.gamer.turned!
    
    # swapped, then swap letters back to stock
    if last_turn.swapped?
      self.stock_letters += (last_turn.start_letters - last_turn.end_letters)
      save
    end

    # create new turn for gamer 
    new_turn =Turn.create(
      game_id: id, 
      user_id: last_turn.user.id,
      gamer_id: last_turn.gamer.id,
      start_letters: adjust_letters(last_turn.end_letters),
      sequence_nbr: turns.order(:sequence_nbr).last.sequence_nbr + 1
    )
    
    logger.info '@@@@@@@@@@ game goto_next new_turn.start_letters:' + new_turn.start_letters.to_s
    # end-of-game
    if new_turn.start_letters.count == 0       #stock_letters.count == 0 and last_turn.end_letters.count == 0
      
      # update gamers
      # byebug
      take_over_points = 0
      gamers.where.not(sequence_nbr: 0).each do |g|

        # collect points on shelfs: minus for other than current gamer
        g_last_turn = g.turns.order(:sequence_nbr).last
        if g != last_turn.gamer
          g_last_points = 0
          g_last_turn.start_letters.each{ |sl| g_last_points += sl[1]  }
          g_last_turn.score = g_last_points * -1
          g_last_turn.save
          take_over_points += g_last_points
        end
        
      end
      # update last turn and gamer who played out
      last_turn.score += take_over_points
      last_turn.save
      last_turn.gamer.score += take_over_points
      last_turn.gamer.plays_out!
      played_out!                             # end of game, set positions
      
    # not eog, set next turn/gamer to play
    else
      next_turn = Turn.find_by( game_id: id, sequence_nbr: last_turn.sequence_nbr + 1)
      next_turn.started = last_turn.ended
      next_turn.get_turn!
    end

    return new_turn   # to update board and current gamers' shelf
  end
  
  # Save laid_letters in the board
  def letters_to_board(letters)
    # logger.info 'ltrs= ' + letters.to_s
    # logger.info 'll voor: ' + laid_letters.to_s
    letters.each do |ll|
      self.laid_letters[ll[0]][ll[1]] = [ll[2], ll[3]]
    end
    logger.info 'letters_to_board voor save: '
    save
    logger.info 'letters_to_board na save: '
  end
    
  # Available letters from lettersets
  def available_letters
    ltrs = []
    letter_set.letter_amount_points.each do |k, v|
      ltrs << k.to_s unless k == '?'
    end
    return ltrs.sort
  end
  
  private #-----------------------------------------------------------------------------------

  # Callbacks
  before_create do
    self.laid_letters = Array.new(15){Array.new(15)}
    self.stock_letters = letter_set.all_letters_points  #.shuffle
    self.words_list_groups = set_words_list_groups
    self.invite_time = 10.hours
    # self.play_time = 10.hours
  end

  before_save do
    if startable?
      self.stock_letters = letter_set.all_letters_points  #.shuffle
      self.words_list_groups = set_words_list_groups
      self.play_time = calc_play_seconds
    end
  end
  
  # calculate play_time in seconds
  def calc_play_seconds
    @time_days.to_i * 86400 + @time_hours.to_i * 3600 + @time_minutes.to_i * 60
  end
    
  # collect groups and id's of used wordlist
  def set_words_list_groups
    # Read wordslists
    wl_groups = []
    WordsList.where( {:name => words_list.name}, :order => "group").each do |wl|
      wl_groups << [wl.group, wl.id] if wl.id != words_list.id
    end
    return wl_groups.sort
  end
  
  # State Machine
  aasm column: :state do
    state :startable, initial: true
    state :playable
    state :pre_abort
    state :in_play    #,  before_enter: :start_the_timer
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
      transitions from: :in_play, to: :ended, after: :set_position_gamers
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

  # start time
  # def start_the_timer
  #   self.started_at = Time.now
  # end
  
  # invites are completed, resequence the players/turns, delete non-acceptants turns
  def init_play
    # self.started_at = Time.now
    logger.info 'game.started_at: ' + started_at.to_s
    seq = 0
    gamers.order(:sequence_nbr).each do |g|
      turn = Turn.find_by(game_id: id, user_id: g.user_id)
      if g.accepted?
        seq += 1
        g.sequence_nbr = seq
        g.game_started      # state --> waiting
        g.save
        turn.sequence_nbr = seq
        if seq == 1 #first player
          logger.info 'game.first player: ' + g.user_id.to_s
          turn.started = started_at
          turn.get_turn 
        end
        turn.save!
      # delete turn of not accepting gamer
      else
        g.sequence_nbr = 0
        g.save
        turn.delete if turn
      end
    end
    save
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
      logger.info 'tlp: true'
      incompletion  # pre_abort
      save
      # errors.add(:gamers, :too_less_gamers)
      errors[:base] << :too_less_gamers
      true
    else
      logger.info 'tlp: false'
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
    gamers.where(state: 'accepted').count > 0
  end

  # end of game, position_gamers
  def set_position_gamers
    pos = 1
    prev_score = -1
    gamers.order(score: :desc).each_with_index do |g, idx|
      if prev_score != -1
        if g.score != prev_score
          pos += 1
        end
      end
      g.position = pos
      prev_score = g.score
      g.save
    end
  end
  
end
