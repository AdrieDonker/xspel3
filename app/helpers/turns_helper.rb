module TurnsHelper
  
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
    logger.info direction
    logger.info direction_oke
    
    return 1 unless direction_oke # not all hori- of vertical

    # Create new_game with laid_letters in it
    new_game = deep_copy(@turn.game.laid_letters)
    letters.each{|ltr| new_game[ltr[0]][ltr[1]] = [ltr[2], ltr[3]] }
  
    # check filled from first to last letter
    filled = true
    if letters.size > 1

      # Horizontaal
      if direction == 'h'
        # From 1e+1 upto last-1 column
        (letters.first[1] + 1).upto(letters.last[1] - 1){ |x| filled = false if new_game[letters.first[0]][x].nil? }

      # Vertical
      elsif direction == 'v'
        # Van 1e+1 tot laatste-1 row
        (letters.first[0] + 1).upto(letters.last[0] - 1){ |x| filled = false if new_game[x][letters.first[1]].nil? }
      end
    end
    
    return 2 unless filled # letters not filled to one word
      
    # First turn, check if center is used
    lays_oke = false
    if @game.laid_letters.flatten.compact.size == 0
      letters.each do |x|
        lays_oke = true if x[0] == 7 and x[1] == 7
      end
      res = "Eerste word moet centrum kruizen" unless lays_oke

    # Check op aanliggen aan letters in spel
    else
      letters.each do |x|
        pos_0 = [x[0]-1, x[1]] if x[0] > 0     # boven
        pos_1 = [x[0], x[1]+1] if x[1] < 14    # rechts
        pos_2 = [x[0]+1, x[1]] if x[0] < 14    # onder
        pos_3 = [x[0], x[1]-1] if x[1] > 0     # links

        lays_oke = true if pos_0 and @game.laid_letters[pos_0[0]][pos_0[1]]
        lays_oke = true if pos_1 and @game.laid_letters[pos_1[0]][pos_1[1]]
        lays_oke = true if pos_2 and @game.laid_letters[pos_2[0]][pos_2[1]]
        lays_oke = true if pos_3 and @game.laid_letters[pos_3[0]][pos_3[1]]
      end
      res = "Letters moeten aanliggen aan de rest" 
    end
    
    return 3 unless lays_oke
    
    return 0 # Oke!
  end

  # Check the words
  def words_nok(letters)
    
    # Collect the words
    words = collect_words(letters)
    
    # Test the words
    # Init
    wrong_words = []      # zelfde [[<word>, <punten>], ...]
    search_parts = []             # [[<search_part>, <word>, <punten>, <words_lists_id>], ...]

    # Collect lengths+word for searching in lists
    words.each do |wrd|
      word = wrd[0]
      if word.size > 4
        search_part = (word.size < 10 ? '0' : '') + word.size.to_s
          search_parts << [search_part + word, word, wrd[1]]

      # Short words direct
      else
        lst = @game.words_lists.words
        unless lst.include?(word.downcase)
          wrong_words << [word, wrd[1]]
        end
      end
    end
    search_parts.sort!

    # Get words_lists_ids
    wl_ids = []
    search_parts.each do |z|
      temp = nil
      @game.words_list_groups.each do |w|
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
      wls = Wordslist.find wl_ids   # rescue nil

      # Check the words (search_parts => # [[<search_part>, <word>, <points>, <words_lists_id>], ...])
      search_parts.each do |z|
        # Is it in the list?
        unless wls.select{|w| w.id == z[3]}.first.words.include?(z[1].downcase)
          wrong_words << [z[1], z[2]]
        end
      end
    end
    return wrong_words
  end
  
  # Collect the words
  def collect_words
  
    # Init
    new_game = game_with_last_turn(spel, letters)

    words = []    # [[<word>, <points>, <row>, <column>, h/v], [<word>, <points..  ] ]
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
      new_column -= 1 while new_column >= 0 and @game.laid_letters[start_row][new_column] != nil
      start_column = new_column + 1

      new_column = end_column + 1
      new_column += 1 while new_column < 15 and @game.laid_letters[start_row][new_column] != nil
      end_column = new_column - 1

      word = ''; points = 0; ww = 1
      if start_column != end_column
        start_column.upto(end_column) do |x|
          word += new_game[start_row][x][0]
          # * lettervalue
          points += (new_game[start_row][x][1] * (new_game[start_row][x][2].nil? ? 1 :  new_game[start_row][x][2]) )
          # * wordvalue
          ww = ww * new_game[start_row][x][3] unless new_game[start_row][x][3].nil?
        end
        words << [word, points * ww, start_row, start_column, 'h']
      end

      # Extra words vertical
      letters.each do |x|
        new_row = x[0] - 1
        new_row -= 1 while new_row >= 0 and @game.laid_letters[new_row][x[1]] != nil
        start_row = new_row + 1

        new_row = x[0] + 1
        new_row += 1 while new_row < 15 and @game.laid_letters[new_row][x[1]] != nil
        end_row = new_row - 1

        if start_row != end_row
          ww = 1
          word = ''; points = 0
          start_row.upto(end_row) do |y|
            word += new_game[y][x[1]][0]
            points += (new_game[y][x[1]][1] * (new_game[y][x[1]][2].nil? ? 1 :  new_game[y][x[1]][2]) )
            ww = ww * new_game[y][x[1]][3] unless new_game[y][x[1]][3].nil?
          end
          words << [word, points * ww, start_row, x[1], 'v']
        end
      end

    # Vertical
    else
      # Mainword Vertical
      new_row = start_row - 1
      new_row -= 1 while new_row >= 0 and @game.laid_letters[new_row][start_column] != nil
      start_row = new_row + 1

      new_row = end_row + 1
      new_row += 1 while new_row < 15 and @game.laid_letters[new_row][start_column] != nil
      end_row = new_row - 1

      word = ''; points = 0; ww = 1
      if start_row != end_row
        start_row.upto(end_row) do |x|
          word += new_game[x][start_column][0]
          # * lettervalue
          points += (new_game[x][start_column][1] * (new_game[x][start_column][2].nil? ? 1 :  new_game[x][start_column][2]) )
          # * wordvalue
          ww = ww * new_game[x][start_column][3] unless new_game[x][start_column][3].nil?
        end
        words << [word, points * ww, start_row, start_column, 'v']
      end

      # Extra words horizontal
      letters.each do |x|
        new_column = x[1] - 1
        new_column -= 1 while new_column >= 0 and @game.laid_letters[x[0]][new_column] != nil
        start_column = new_column + 1

        new_column = x[1] + 1
        new_column += 1 while new_column < 15 and @game.laid_letters[x[0]][new_column] != nil
        end_column = new_column - 1

        if start_column != end_column
          ww = 1
          word = ''; points = 0
          start_column.upto(end_column) do |y|
            word += new_game[x[0]][y][0]
            points += (new_game[x[0]][y][1] * (new_game[x[0]][y][2].nil? ? 1 :  new_game[x[0]][y][2]) )
            ww = ww * new_game[x[0]][y][3] unless new_game[x[0]][y][3].nil?
          end
          words << [word, points * ww, x[0], start_column, 'h']
        end
      end
    end
    return words    
    
  end
  
  private # ---------------------------------------------------------------------------------

  # Return: copy of @game, including current turn
  def game_with_last_turn(letters)
    new_game = deep_copy(@game.laid_letters)
    letters.each do |ltr|
      lw = 1; ww = 1
      
      # Add double/triple letter/word if in layout
      unless @game.board.layout[ltr[0]][ltr[1]].nil?
        factor_lw = @game.board.layout[ltr[0]][ltr[1]].split('_')
        factor = factor_lw[0].to_i
        if factor_lw[1] == 'l'
          lw = factor
        else
          ww = factor
        end
      end
      new_game[ltr[0]][ltr[1]] = [ltr[2], ltr[3], lw, ww]
    end
    return new_game
  end
end
