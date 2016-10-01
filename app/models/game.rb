class Game < ApplicationRecord
  include AASM
  
  belongs_to :board
  belongs_to :letter_set
  belongs_to :words_list
  belongs_to :owner, class_name: "User"  
  # belongs_to :starter, class_name: "User"
  has_many :gamers
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
    self.users.each do |g|
      gn << g.name
    end
    return gn
  end
  
  # Create turn for gamer
  def create_turn(gamer)
    # if self.game.turns.count == 0
      Turn.create( 
        user_id: gamer.id, 
        game_id: self.id
      )
    # end
  end
  
  # Return (max 7) random letters
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
  
  # Return 
  def last_played(attr)
    unless turns.last.nil?
      lp = turns.last
      case attr
        when :user
          lp.user.name
        when :words
          lp.words
        when :points
          lp.score
        else
          'fout'
      end
    else
      '(geen)'
    end
  end

  private #-----------------------------------------------------------------------------------

  # Callbacks
  before_create do
    self.laid_letters = Array.new(15){Array.new(15)}
    self.stock_letters = letter_set.all_letters_points  #.shuffle
    self.words_list_groups = set_words_list_groups
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
  
  # State Machine
  # aasm_column :state  #[DEPRECATION] aasm_column is deprecated. Use aasm.attribute_name instead
  aasm.attribute_name :state
  # aasm column: :state do
  aasm do
    state :startable, initial: true
    state :playable
    state :pre_aborted
    state :in_play
    state :ended
    state :aborted
    
    event :start_now do
      transitions from: :startable, to: :playable, guard: :send_invites
      # transitions startable: :playable #, guard: :send_invites
    end
    event :play_now do
      transitions from: :playable, to: :in_play, guard: :invites_completed
    end
    event :ending do
       transitions in_play: :ended
    end
      
  end
  
  def send_invites
    # errors[:base] << "Invites versturen mislukt!"
    # logger.info "Invites niet verstuurd"
    true
  end
    
  def invites_completed
    if gamers.where(state: 'invited').count > 0 
      errors[:base] << "Er zijn nog lopende uitnodigingen!"
      false
    elsif gamers.where(state: 'accepted').count < 2
      errors[:base] << "Er zijn minder dan 2 geaccepteerde uitnodigingen!"
      false
    else
      true
    end
  end
  

end
