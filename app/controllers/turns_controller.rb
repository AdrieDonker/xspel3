class TurnsController < ApplicationController
  before_action :set_turn, only: [:pass, :play, :swap, :blank, :too_late]

  # params: laid_letters (row_col_letter_points_row_...), js_time (miliseconds), js_start_time (milliseconds)
  def play
    
    # letters to array [ [row, column, letter, points], [...  ]
    letters = []
    params[:laid_letters].split('_').each_slice(4) do |ll|
      letters << [ll[0].to_i, ll[1].to_i, ll[2], ll[3].to_i]
    end
    logger.info '@@@@@@@@@@ ctrl letters: ' + letters.to_s

    # Check laying of letters
    @error = @turn.laid_oke(letters)
    if  @error.blank?
      
      # Check the words
      @error = @turn.words_nok(letters)
      if @error.size == 0

        # Update game and set next turn
        # @turn.started = Time.at( params[:js_start_time].to_i / 1000.0 )
        @turn.ended = Time.at( params[:js_time].to_i / 1000.0 )
        # logger.info 'turn_ctrl - js_start_time: ' + @turn.started.to_s
        logger.info 'turn_ctrl - js_time: ' + @turn.ended.to_s
        @turn.update_turn(letters)
        @game.letters_to_board(letters)
        @turn = @game.goto_next(@turn)    # @turn gets next_turn

        # to all players
        broadcast(letters)

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

    # answered YES
    if params[:answer]
      @turn.end_letters = @turn.start_letters
      @turn.ended = Time.at(params[:js_time].to_i/1000)
      @turn.passing
      @turn.save
      @turn = @game.goto_next(@turn)
      
      broadcast(nil)
      # ActionCable.server.broadcast 'game_channel',
      #   gamer_user_id: current_user.id.to_s,
      #   game_id: @game.id.to_s,
      #   gamers: render(partial: 'games/gamers')
      
      # head :ok 
      # redirect_to play_game_path(@game)
      
    # JS: ask confirmmation
    else
    end
  end
  
  def swap
    # answered YES
    if params[:answer]
      swap_letters = []
      params[:letters].each {|k, v| swap_letters << [v[0], v[1].to_i]}
      
      # delete swap letters
      @turn.set_end_letters(swap_letters)
      @turn.ended = Time.at(params[:js_time].to_i/1000)
      @turn.swapping
      @turn.save
      @turn = @game.goto_next(@turn)
      
      broadcast(nil)

      # render :swap_done
      # redirect_to play_game_path(@game)
      
    # JS: ask confirmmation
    end
  end

  def too_late
    @turn.end_letters = @turn.start_letters
    @turn.ended = Time.at(params[:js_time].to_i/1000)
    @turn.expiring
    @turn.save
    @turn = @game.goto_next(@turn)
    
    broadcast(nil)
  end
  
  # GET: exchange blank JS
  def blank
    if params[:answer]
    
    # JS: choose
    else
      @letters = @game.available_letters
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
    
    def broadcast(ltrs)
      ActionCable.server.broadcast 'game_channel',
        gamer_user_id: current_user.id.to_s,
        game_id: @game.id.to_s,
        board: (ltrs.nil? ? [] : ltrs),
        shelf: @turn.start_letters,
        gamers: render_to_string(partial: 'games/gamers')  #, locals: {js_time: params[:js_time]})
      head :ok
    end

end
