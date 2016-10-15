class TurnsController < ApplicationController
  before_action :set_turn, only: [:pass, :play, :swap, :blank]

  def play
    
    # letters to array [ [row, column, letter, points], [...  ]
    letters = []
    laid_letters.split('_').each_slice(4) do |ll|
      letters << ll
    end

    # Check laying of letters
    if laid_oke(letters) == 0
      
      # Check the words
      if words_nok(letters) == ''
      
        # Next turn
        stop
        
        
      # Wrong words
      else
        # show wrong words
        
      end
      # broadcast
      #   laid_letters and update board
      #   <gamer> played <words> <points>
      @turn.
      

    # Laying not oke
    else
      # show wrong laying
      
    end
    
  end
  
  def pass
    set_turn

    # answered YES
    if params[:answer]
      @turn.passing
      @turn.score = 0
      @turn.end_letters = @turn.start_letters
      @turn.save
      @game.goto_next(@turn)
      
      redirect_to play_game_path(@game)
      
    # JS: ask confirmmation
    else
    end
  end
  
  def swap
    # answered YES
    if params[:answer]
      swap_letters = []
      params[:letters].each {|k, v| swap_letters << [v[0].to_sym, v[1].to_i]}
      
      # delete swap letters
      @turn.end_letters = @turn.start_letters
      swap_letters.each do |sl|
        pos = @turn.end_letters.rindex(sl)
        @turn.end_letters.slice!(pos) if pos
      end

      logger.info 'swap letters: ' + swap_letters.to_s
      logger.info 'start letters: ' + @turn.start_letters.to_s
      logger.info 'end letters: ' + @turn.end_letters.to_s
      @turn.swapping
      @turn.score = 0
      @turn.save
      @turn = @game.goto_next(@turn)
      
      render :swap_done
      # redirect_to play_game_path(@game)
      
    # JS: ask confirmmation
    end
  end

  # GET: exchange blank JS
  def blank
    if params[:answer]
    
    # JS: choose
    else
      @letters = @game.letters
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_turn
      @game = Game.find(params[:game_id])
      @turn = Turn.find(params[:turn_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def turn_params
      params.require(:turn).permit(:user_id, :game_id, :score, :sequence_nbr, :bingo, :state, :start_letters, :end_letters, :started, :ended)
    end
end
