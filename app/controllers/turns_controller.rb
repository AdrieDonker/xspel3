class TurnsController < ApplicationController
  before_action :set_turn, only: [:pass, :play, :swap, :blank]

  def play
    
    # letters to array [ [row, column, letter, points], [...  ]
    letters = []
    params[:laid_letters].split('_').each_slice(4) do |ll|
      letters << [ll[0].to_i, ll[1].to_i, ll[2], ll[3].to_i]
    end

    # Check laying of letters
    @error = @turn.laid_oke(letters)
    if  @error.blank?
      
      # Check the words
      @error = @turn.words_nok(letters)
      if @error.size == 0

        # Update game and set next turn
        @turn.update_turn(letters)
        # @turn.playing
        # @turn.save
        @game.letters_to_board(letters)
        @turn = @game.goto_next(@turn)

        ActionCable.server.broadcast 'game_channel',
          game_id: @game.id,
          board: letters,
          shelf: @turn.start_letters,
          gamers: render(partial: 'games/gamers')
        head :ok
        # render :play_done

      # Wrong words
      else
        render :play_error
      end

    # Laying not oke
    else
      render :play_error
    end
    # stop
  end
  
  def pass
    # set_turn

    # answered YES
    if params[:answer]
      @turn.end_letters = @turn.start_letters
      @turn.passing
      @turn.save
      @turn = @game.goto_next(@turn)
      
      ActionCable.server.broadcast 'game_channel',
      # ActionCable.server.broadcast "games_#{@game.id}_channel",
        game_id: @game.id,
        # action: 'pass',
        gamers: render(partial: 'games/gamers')
      
      head :ok 
      # redirect_to play_game_path(@game)
      
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
      @turn.set_end_letters(swap_letters)
      @turn.swapping
      @turn.save
      @turn = @game.goto_next(@turn)
      
      ActionCable.server.broadcast 'game_channel', 
        gamers: render(partial: 'games/gamers')
      head :ok 

      # render :swap_done
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
