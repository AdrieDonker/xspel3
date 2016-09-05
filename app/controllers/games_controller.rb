class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games.js
  def index
    @games = []
    if current_user
      @games = Game.where(owner_id: current_user.id).order("created_at DESC")
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    # case @game.state
    #   when 'new_game'
    #     render 'select_players'
    #   when 'startable'
    #   else
    # end
  end

  # Only JS
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games.js
  def create
    params[:game][:user_ids].reject!(&:empty?)
    @game = Game.new(game_params)
    @game.owner = current_user
    # @game.users << User.find(params[:game][:user_ids]) 
    if @game.save
      flash.now[:notice] = (t :model_created, name: @game.name, model: Game.model_name.human)
      redirect_to action: :index
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:name, :board_id, :letter_set_id, :words_list_id, :extra_words_lists, :user_ids => [])
    end
end
