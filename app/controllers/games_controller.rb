class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games.js
  def index
    @games = []
    if current_user
      @games = current_user.games.order("created_at DESC")
    end
    render partial: 'in_play', locals: {games: @games}
  end

  # GET /games/1
  # GET /games/1.json
  def show
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
    @game = Game.new(game_params)
    @game.users << current_user
    if @game.save
      flash.now[:notice] = (t :model_created, name: @game.name, model: Game.model_name.human)
      render :add_game
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:name, :board_id, :letter_set_id, :words_list_id, :extra_words_lists, :text)
    end
end
