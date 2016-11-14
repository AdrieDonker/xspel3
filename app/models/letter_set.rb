class LetterSet < ApplicationRecord
  serialize   :letter_amount_points       # hash {‘A’ => [6, 1], ‘B’ => [2, 3]], ..  <letter> => [<aantal>, <punten>]
  validates :name, presence: true, uniqueness: true

  def lap=(l_a_p)
    lap_new = []
    l_a_p.each do |value|
      val = value.gsub(/\s\s+/, "")
      if val.gsub(/\s+/, "") != ""
        vals = val.split
        vals[2] = 0 if vals[0] == '?'
        lap_new << [vals[0], [vals[1].to_i, vals[2].to_i] ]
      end
    end
    self.letter_amount_points = lap_new.sort
  end

  def lap
    self.letter_amount_points ||= []
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

  # Create 2 standard lettersets
  def self.create_standard_letter_sets
    sls1 = LetterSet.new
    sls1.name = 'standaard'
    sls1.letter_amount_points = 
      {:A=>[6, 1], :B=>[2, 3],  :C=>[2, 5], :D=>[5, 1], :E=>[18, 1], :F=>[2, 4], 
       :G=>[3, 3], :H=>[2, 4],  :I=>[4, 1], :J=>[2, 4], :K=>[3, 3],  :L=>[3, 3], 
       :M=>[3, 3], :N=>[10, 1], :O=>[6, 1], :P=>[2, 3], :Q=>[1, 10], :R=>[5, 2], 
       :S=>[5, 2], :T=>[5, 2],  :U=>[3, 4], :V=>[2, 4], :W=>[2, 5],  :X=>[1, 8], 
       :Y=>[1, 8], :Z=>[2, 4],  :""=>[2, 0]}
    sls1.save

    sls2 = LetterSet.new
    sls2.name = 'wordfeud NL'
    sls2.letter_amount_points =
      {:A=>[7, 1], :B=>[2, 4],  :C=>[2, 5], :D=>[5, 2], :E=>[18, 1], :F=>[2, 4], 
       :G=>[3, 3], :H=>[2, 4],  :I=>[4, 2], :J=>[2, 4], :K=>[3, 3],  :L=>[3, 3], 
       :M=>[3, 3], :N=>[11, 1], :O=>[6, 1], :P=>[2, 4], :Q=>[1, 10], :R=>[5, 2], 
       :S=>[5, 2], :T=>[5, 2],  :U=>[2, 4], :V=>[2, 4], :W=>[2, 5],  :X=>[1, 8], 
       :Y=>[1, 8], :Z=>[2, 5],  :""=>[2, 0]}
    sls2.save
  end
  
end
