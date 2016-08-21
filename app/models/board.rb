class Board < ApplicationRecord
  serialize :layout #, Array
  
  # Return: (en save) standaard bord als niet bestaat
  def self.create_standard_board
    sb = Board.new
    lo = Array.new(15) { Array.new(15) }
    lo[0][0] = lo[0][7] = lo[0][14] =    lo[7][0] = lo[7][14] =    lo[14][0] = lo[14][7] = lo[14][14] = '3_w'
    lo[0][3] = lo[0][11]=    lo[2][6] = lo[2][8] =    lo[3][0] = lo[3][7] = lo[3][14] =    lo[6][2] = lo[6][6] = lo[6][8] = lo[6][12] =
      lo[7][3] = lo[7][11] =
      lo[14][3] = lo[14][11]=    lo[12][6] = lo[12][8] =    lo[11][0] = lo[11][7] = lo[11][14] =    lo[8][2] = lo[8][6] = lo[8][8] = lo[8][12] = '2_l'
    lo[1][1] = lo[1][13] =    lo[2][2] = lo[2][12] =    lo[3][3] = lo[3][11] =    lo[4][4] = lo[4][10] =
      lo[7][7] =
      lo[13][1] = lo[13][13] =    lo[12][2] = lo[12][12] =    lo[11][3] = lo[11][11] =    lo[10][4] = lo[10][10] = '2_w'
    lo[1][5] = lo[1][9] =    lo[5][1] = lo[5][5] = lo[5][9] = lo[5][13] = 
      lo[13][5] = lo[13][9] =    lo[9][1] = lo[9][5] = lo[9][9] = lo[9][13] = '3_l'
    sb.layout = lo
    sb.name = 'standaard'
    sb.save
  end

end
