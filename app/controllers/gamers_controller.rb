class GamersController < ApplicationController
  before_action :set_gamer, only: [:invite]

  # handle invite
  def invite
    set_gamer

    # answered
    if params[:answer]
      if params[:answer] == 'oke'
        @gamer.accept!
        if check_play_now
          redirect_to play_game_path(@game)
        
        # too less players
        elsif @game.pre_abort?
          redirect_to games_path
          
        # not all players reacted
        else
          redirect_to play_game_path(@game)
        end
        
      elsif params[:answer] == 'nok'
        @gamer.reject!
        check_play_now
        redirect_to games_path
      
      else
      end
      
    # do the invite
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gamer
      @gamer = Gamer.find(params[:gamer_id])
      @game = Game.find(params[:game_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gamer_params
      params.require(:gamer).permit(:game_id, :user_id, :sequence_nbr, :score, :state, :position)
    end
    
    # Check if playing can start
    def check_play_now
      if @game.may_play_now?
        @game.started_at = Time.now
        @game.play_now!
        
        # broadcast
        #  game is started
        #  update buttons/state of the players
        true
      else
        false
      end
    end
    
end
