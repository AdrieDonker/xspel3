class Turn < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :game
  belongs_to :gamer

  # attribute :
  serialize :start_letters      # [ [<letter>, <points>], [<.... ]
  serialize :end_letters
  serialize :laid_letters
  serialize :words
  
  # Return: positions of laid letters are:
  #  ''= oke
  #  not_same_direction (hori- of vertical)
  #  first_turn_must_cross_center
  #  not_filled_up_to_word
  #  not_connected_to_others
  def laid_oke(letters)

    # check same direction
    direction = 'h'
    direction_oke = true
    if letters.size > 1

      # Horizontaal
      if letters[0][0] == letters[1][0]
        direction = 'h'
        2.upto(letters.size-1){|x| direction_oke = false if letters[x][0] != letters[0][0]}
      # Vertical
      elsif letters[0][1] == letters[1][1]
        direction = 'v'
        2.upto(letters.size-1){|x| direction_oke = false if letters[x][1] != letters[0][1]}
      # Meerdere is fout
      else
        direction_oke = false
      end
    end

    return :not_same_direction unless direction_oke # not all hori- of vertical

    # First turn, check if center is used
    cross_center = true
    first_turn = (game.laid_letters.flatten.compact.size == 0)
    if first_turn
      cross_center = false
      letters.each do |x|
        cross_center = true if x[0] == 7 and x[1] == 7
      end
    end
    
    return :first_turn_must_cross_center unless cross_center # first turn, not crossing center
    
    # Create new_laid_letters with laid_letters in it
    new_laid_letters = game.laid_letters
    new_laid_letters.freeze
    letters.each{|ltr| new_laid_letters[ltr[0]][ltr[1]] = [ltr[2], ltr[3]] }
  
    # check filled from first to last letter
    filled = true
    if letters.size > 1

      # Horizontaal
      if direction == 'h'
        # From 1e+1 upto last-1 column
        (letters.first[1] + 1).upto(letters.last[1] - 1){ |x| filled = false if new_laid_letters[letters.first[0]][x].nil? }

      # Vertical
      elsif direction == 'v'
        # Van 1e+1 tot laatste-1 row
        (letters.first[0] + 1).upto(letters.last[0] - 1){ |x| filled = false if new_laid_letters[x][letters.first[1]].nil? }
      end
    end
    
    return :not_filled_up_to_word unless filled # letters not filled to one word
      
    # Check op aanliggen aan letters in spel
    connected = true
    if !first_turn
      connected = false
      letters.each do |x|
        pos_0 = [x[0]-1, x[1]] if x[0] > 0     # boven
        pos_1 = [x[0], x[1]+1] if x[1] < 14    # rechts
        pos_2 = [x[0]+1, x[1]] if x[0] < 14    # onder
        pos_3 = [x[0], x[1]-1] if x[1] > 0     # links

        connected = true if pos_0 and game.laid_letters[pos_0[0]][pos_0[1]]
        connected = true if pos_1 and game.laid_letters[pos_1[0]][pos_1[1]]
        connected = true if pos_2 and game.laid_letters[pos_2[0]][pos_2[1]]
        connected = true if pos_3 and game.laid_letters[pos_3[0]][pos_3[1]]
      end
    end

    return :not_connected_to_others unless connected  # not connected to other letters
    
    return # Oke!
  end

  # Find wrong words
  def words_nok(letters)
    
    # Collect the words
    collect_words(letters)

    # Test the words
    # Init
    wrong_words = []          
    search_parts = []         # [[<search_part>, <word>, <punten>, <words_lists_id>], ...]

    # Collect lengths+word for searching in lists
    words.each do |wrd|
      word = wrd[0]
      if word.size > 4
        search_part = (word.size < 10 ? '0' : '') + word.size.to_s
          search_parts << [search_part + word, word, wrd[1]]

      # Short words direct
      else
        lst = game.words_list.words
        unless lst.include?(word.downcase)
          wrong_words << word  #, wrd[1]]
        end
      end
    end
    # search_parts.sort!

    # Get words_lists_ids
    wl_ids = []
    search_parts.each do |z|
      temp = nil
      game.words_list_groups.sort.each do |w|
        a = z[0]; b = w[0]
        if z[0].downcase >= w[0]                      # bewaar laatste goede = de goede
          temp = w
        elsif temp
          wl_ids << temp[1]
          z[3] = temp[1]     # plak id erbij
          break
        end
      end
    end

    # Lees words_listsen
    if wl_ids.size > 0
      wls = WordsList.find wl_ids   # rescue nil

      # Check the words (search_parts => # [[<search_part>, <word>, <points>, <words_lists_id>], ...])
      search_parts.each do |z|
        # Is it in the list?
        unless wls.select{|w| w.id == z[3]}.first.words.include?(z[1].downcase)
          wrong_words << z[1] #, z[2]]
        end
      end
    end
    # logger.info wrong_words
    return wrong_words
  end
  
  # Collect the words
  def collect_words(letters)
  
    # Init
    new_laid_letters = add_to_laid_letters(letters)
    # new_laid_letters.each do |ll|
    #   logger.info ll
    # end

    self.words = []    # [[<word>, <points>, <row>, <column>, h/v], [<word>, <points..  ] ]
    direction = 'h'
    direction = 'v' if letters.size > 1 and letters[0][1] == letters[1][1]  #1 letter is 'h'

    start_row = letters.first[0]
    start_column = letters.first[1]
    end_row = letters.last[0]
    end_column = letters.last[1]

    # Horizontaal
    if direction == 'h'

      # Mainword horizontal
      new_column = start_column - 1
      new_column -= 1 while new_column >= 0 and new_laid_letters[start_row][new_column] != nil
      start_column = new_column + 1

      new_column = end_column + 1
      new_column += 1 while new_column < 15 and new_laid_letters[start_row][new_column] != nil
      end_column = new_column - 1

      word = ''; points = 0; ww = 1
      if start_column != end_column
        start_column.upto(end_column) do |x|
          word += new_laid_letters[start_row][x][0]
          # * lettervalue
          points += (new_laid_letters[start_row][x][1] * (new_laid_letters[start_row][x][2].nil? ? 1 :  new_laid_letters[start_row][x][2]) )
          # * wordvalue
          ww = ww * new_laid_letters[start_row][x][3] unless new_laid_letters[start_row][x][3].nil?
        end
        self.words << [word, points * ww, start_row, start_column, 'h']
      end

      # Extra words vertical
      letters.each do |x|
        new_row = x[0] - 1
        new_row -= 1 while new_row >= 0 and new_laid_letters[new_row][x[1]] != nil
        start_row = new_row + 1

        new_row = x[0] + 1
        new_row += 1 while new_row < 15 and new_laid_letters[new_row][x[1]] != nil
        end_row = new_row - 1

        if start_row != end_row
          ww = 1
          word = ''; points = 0
          start_row.upto(end_row) do |y|
            word += new_laid_letters[y][x[1]][0]
            points += (new_laid_letters[y][x[1]][1] * (new_laid_letters[y][x[1]][2].nil? ? 1 :  new_laid_letters[y][x[1]][2]) )
            ww = ww * new_laid_letters[y][x[1]][3] unless new_laid_letters[y][x[1]][3].nil?
          end
          self.words << [word, points * ww, start_row, x[1], 'v']
        end
      end

    # Vertical
    else
      # Mainword Vertical
      new_row = start_row - 1
      new_row -= 1 while new_row >= 0 and new_laid_letters[new_row][start_column] != nil
      start_row = new_row + 1

      new_row = end_row + 1
      new_row += 1 while new_row < 15 and new_laid_letters[new_row][start_column] != nil
      end_row = new_row - 1

      word = ''; points = 0; ww = 1
      if start_row != end_row
        start_row.upto(end_row) do |x|
          word += new_laid_letters[x][start_column][0]
          # * lettervalue
          points += (new_laid_letters[x][start_column][1] * (new_laid_letters[x][start_column][2].nil? ? 1 :  new_laid_letters[x][start_column][2]) )
          # * wordvalue
          ww = ww * new_laid_letters[x][start_column][3] unless new_laid_letters[x][start_column][3].nil?
        end
        self.words << [word, points * ww, start_row, start_column, 'v']
      end

      # Extra words horizontal
      letters.each do |x|
        new_column = x[1] - 1
        new_column -= 1 while new_column >= 0 and new_laid_letters[x[0]][new_column] != nil
        start_column = new_column + 1

        new_column = x[1] + 1
        new_column += 1 while new_column < 15 and new_laid_letters[x[0]][new_column] != nil
        end_column = new_column - 1

        if start_column != end_column
          ww = 1
          word = ''; points = 0
          start_column.upto(end_column) do |y|
            word += new_laid_letters[x[0]][y][0]
            points += (new_laid_letters[x[0]][y][1] * (new_laid_letters[x[0]][y][2].nil? ? 1 :  new_laid_letters[x[0]][y][2]) )
            ww = ww * new_laid_letters[x[0]][y][3] unless new_laid_letters[x[0]][y][3].nil?
          end
          self.words << [word, points * ww, x[0], start_column, 'h']
        end
      end
    end
    return words.count
    
  end
  
  # Remove used/swapped letters
  def set_end_letters(letters)
    self.end_letters = start_letters
    logger.info 'end_letters=' + end_letters.to_s
    logger.info 'letters=' + letters.to_s
    letters.each do |sl|
      # blank (0 points) adjust
      sl[0] = "?" if sl[1] == 0
      pos = end_letters.rindex(sl)
      if pos
        self.end_letters.slice!(pos) 
      else
        logger.info 'letter (blank?) not found: ' + sl.to_s
      end
    end
  end

  # Update game after good word(s) played
  def update_turn(laid_letters)
    # Extract :<letter>, points
    logger.info '@@@@@@@@@@ update_turn: laid_letters: ' + laid_letters.to_s
    letters = []
    laid_letters.each { |lt| letters << [lt[2], lt[3]] }
    set_end_letters(letters)

    self.laid_letters = laid_letters
    self.score = 0
    words.each { |w| self.score += w[1] }
    self.bingo = (laid_letters.size == 7 ? true : false )
    self.score += 50 if bingo
    self.ended = Time.now
    playing!

  end

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
    state :too_late
    
    event :get_turn, after: :start_turn do
      transitions from: :wait, to: :play
    end
    event :passing, after: :stop_turn do
      transitions from: :play, to: :passed
    end
    event :swapping, after: :stop_turn do
      transitions from: :play, to: :swapped
    end
    event :playing do
      transitions from: :play, to: :played
    end
    event :expiring, after: :stop_turn do
      transitions from: :play, to: :too_late
    end

  end
  
  def start_turn
    gamer.gets_turn!
  end

  def stop_turn
    self.score = 0
    # self.ended = Time.now
  end
  
  # =======================================================
  
  # Return: copy of game.laid_letters, including current turn
  def add_to_laid_letters(letters)
    new_laid_letters = game.laid_letters
    new_laid_letters.freeze   # protect against changes

    # Process all letters
    letters.each do |ltr|
      lw = 1; ww = 1
      
      # Add double/triple letter/word if in layout
      unless game.board.layout[ltr[0]][ltr[1]].nil?
        factor_lw = game.board.layout[ltr[0]][ltr[1]].split('_')
        factor = factor_lw[0].to_i
        if factor_lw[1] == 'l'
          lw = factor
        else
          ww = factor
        end
      end
      # Add letters to laid_letters
      new_laid_letters[ltr[0]][ltr[1]] = [ltr[2], ltr[3], lw, ww]
    end
    return new_laid_letters
  end
 
end
