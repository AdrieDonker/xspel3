class WordsList < ApplicationRecord
  serialize :words
  @@MAX_SIZE = 20000  # maximum ruimte voor words(splitsen als groter)

  def words_spaced
    (words||[]).join(' ')
  end
  
  def words_spaced_to_6
    self.words ||= []
    if words.size > 7
      (words[0..2] + ['...'] + words[-3..-1]).join(' ') + "(#{words.size})"
    else
      words.join(' ')
    end
  end

  def words_spaced=(wrds)
    wrds_a = wrds.split(' ').sort

    # Groter dan 20000, dan opsplitsen
    if wrds.size > @@MAX_SIZE
      part_1 = []
      part_1_size = 0
      wrds_a.each_with_index do |w, idx|
        part_1_size += w.size

        # Te groot, volgenden opslaan
        if part_1_size > @@MAX_SIZE
          create_extra(wrds_a[idx..-1])
          break
        else
          part_1 << w
        end
      end

      # En zelluf
      self.words = part_1
    else
      self.words = wrds_a
    end

  end

  private

  # Maak extra lijsten
  def create_extra(wrs)
    wrs_size = wrs.size
    new_lijst = WordsList.new(:name => name, :group => group + wrs[0])
    new_part = []
    new_part_size = 0

    wrs.each do |w|
      new_part_size += w.size

      if new_part_size > @@MAX_SIZE
        new_lijst.words = new_part
        new_lijst.save
        new_lijst = WordsList.new(:name => name, :group => group + w)
        new_part = []
        new_part << w
        new_part_size = 0
      else
        new_part << w
      end
    end

    # Laatste ?
    if new_part.size > 0
      new_lijst.words = new_part
      new_lijst.save
    end

  end

end
