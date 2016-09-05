class LetterSet < ApplicationRecord
  serialize   :letter_amount_points       # hash {‘A’ => [6, 1], ‘B’ => [2, 3]], ..  <letter> => [<aantal>, <punten>]
  validates :name, presence: true, uniqueness: true

  # Return: 7 random letters uit volledige set
  def select_7
    de_7 = []
    selected = []
    alp = all_letters_points     # [ ['A', 1], ['A', 1], ...]
    letters_tal = aantal_letters # tbv rand
    while selected.size < 7
      new_sel = rand(letters_tal)
      while selected.include?(new_sel)
        new_sel = rand(letters_tal)
      end
      selected << new_sel
      de_7 << alp[new_sel]
    end
    return de_7
  end

  # Return: aantal letters in set
  def aantal_letters
    alle_letters.size
  end

  # Return: alle letters van set: AAAAAABBBCCDDDDEEEEEEEEEEE...
  def alle_letters
    self.letter_amount_points ||= {}
    lap = ''
    letter_amount_points.each do |l, ap|
      lap += l * ap[0]
    end
    lap.split('')
  end

  # Return: Alle unieke letters (zonder blanco)
  def unieke_letters
    ul = []
    self.letter_amount_points ||= {}
    letter_amount_points.each do |k, v|
      ul << k unless k == ' '
    end
    ul
  end

  # Return: Array alle letters van set met punten: [ [letter, punten], [letter, pu .. ]
  def all_letters_points
    self.letter_amount_points ||= {}
    lap = []
    letter_amount_points.each do |l, ap|
      1.upto(ap[0]) do |a|
        lap << [l, ap[1]]
      end
    end
    lap
  end

  # Return: (en save) standaard letterset als niet bestaat
  def self.create_standard_letter_set
    sls = LetterSet.new
    sls.letter_amount_points = 
      {:A=>[6, 1], :B=>[2, 3],  :C=>[2, 5], :D=>[5, 1], :E=>[18, 1], :F=>[2, 4], 
       :G=>[3, 3], :H=>[2, 4],  :I=>[4, 1], :J=>[2, 4], :K=>[3, 3],  :L=>[3, 3], 
       :M=>[3, 3], :N=>[10, 1], :O=>[6, 1], :P=>[2, 3], :Q=>[1, 10], :R=>[5, 2], 
       :S=>[5, 2], :T=>[5, 2],  :U=>[3, 4], :V=>[2, 4], :W=>[2, 5],  :X=>[1, 8], 
       :Y=>[1, 8], :Z=>[2, 4],  :""=>[2, 0]}
    sls.name = 'standaard'
    sls.save
  end
  
end
