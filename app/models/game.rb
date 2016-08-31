class Game < ApplicationRecord
  belongs_to :board
  belongs_to :letter_set
  belongs_to :words_list
  # belongs_to :starter, class_name: "User"
  has_many :gamers
  has_many :users, through: :gamers
  has_many :turns
  
  serialize :laid_letters   # Array.new(15){Array.new(15)}[[<letter>, <punten>], [<letter>, <punten>], ]
  serialize :stock_letters  # Array nog beschikbare letters [[<letter>, <punten>], [<letter>, <punten>], ]
  serialize :words_list_groups # Array: [ [wl_groep, wl_id], ...]
  serialize :extra_words_lists # Array: [ [wl_groep, wl_id], ...]
  
  # State Machine
  # state_machine :state, :initial => :new do
  #   event :add_players do
      # transition :new_game => :startable, if: self.gamers && self.gamers.size > 1
  #   end
  # end
  
  def add_players
    self.gamers = []
  end
  
  # private #-----------------------------------------------------------------------------------

  # Callbacks
  before_validation do
    # self.starter = current_user
    # starter.save
  end
  before_create do
    # self.state = 'new'
    # self.started = Time.now if status
    # self.laid_letters = Array.new(15){Array.new(15)} 
    self.stock_letters = letter_set.all_letters_points.shuffle
    # self.gamers << current_user
  end

  before_save do 
    set_words_list_delen
    set_gamers
  end
  
  def set_words_list_delen
    # Lees bijbehorende lijsten
    wl_groups = []
    WordsList.where( {:name => words_list.name}, :order => "group").each do |wl|
      wl_groups << [wl.group, wl.id] if wl.id != words_list.id
    end
    self.words_list_groups = wl_groups
  end
  
  def set_gamers
    # if @spel_speler_ids

    #   # Verzamel ids
    #   old_ids = spel_spelers.collect{|s| s.speler_id}
    #   used_ids = []
    #   new_ids = []
    #   @spel_speler_ids.each do |s|

    #     # Bestaat al, overslaan
    #     if (idx = old_ids.index(s))
    #       used_ids << old_ids[idx]

    #     # Bestaat nog niet, toevoegen
    #     else
    #       new_ids << s
    #     end
    #   end

    #   # Niet gebruikte wissen (incl beurt)
    #   not_used = old_ids - used_ids
    #   if not_used.size > 0
    #     SpelSpeler.delete_all(["spel_id = ? AND speler_id in ?", id, not_used])
    #     Beurt.delete_all(["spel_id = ? AND speler_id in ?", id, not_used])
    #   end

    #   # Nieuwe toevoegen
    #   if new_ids.size > 0
    #     new_spelers = Speler.find new_ids
    #     self.spel_spelers << new_spelers.collect{ |s| SpelSpeler.new(:speler => s, :status => (s.id == speler_id ? 1 : 0)) }
    #   end

    #   @spel_speler_ids = nil
    # end
  end

  def set_spel_spelers_volgnr
    tel = 0
    spel_spelers.sort{ |x, y| x.volgnr <=> y.volgnr}.each do |s|
      s.volgnr = (tel+=1)
      s.save
    end
  end



end
