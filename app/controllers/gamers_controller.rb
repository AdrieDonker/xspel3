class GamersController < ApplicationController
  before_action :set_gamer, only: [:invite]

  # handle invite get and post
  def invite
    set_gamer

    return unless request.post? # else: JS do the invite

    # answered
    if params[:commit] == t(:do_yes)
      @gamer.accept!
      @game.check_play_now(params[:game_js_time].to_i)
      broadcast
      redirect_to play_game_path(@game), game_js_time: params[:game_js_time].to_i

    else #  params[:commit] == 'no'
      @gamer.reject!
      @game.check_play_now(params[:game_js_time].to_i)
      broadcast
      redirect_to games_path

    end
  end

  private

  # Use callbacks to share layer_1 setup or constraints between actions.
  def set_gamer
    @gamer = Gamer.find(params[:gamer_id])
    @game = Game.find(params[:game_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def gamer_params
    params.require(:gamer).permit(:game_id, :user_id, :sequence_nbr, :score, :state, :position)
  end
  
  def broadcast
    ActionCable.server.broadcast 'game_channel',
                             user_id: current_user.id.to_s,
                             game_id: @game.id.to_s,
                             gamers: render_to_string(partial: 'games/gamers')
  end

end
