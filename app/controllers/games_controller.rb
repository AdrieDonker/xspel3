class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy, :blank]

  # GET /games.js
  def index
    @games = []
    # Games of Gamer and owner
    return unless current_user

    @games = (current_user.games.to_a + Game.where(owner_id: current_user.id).to_a).uniq.sort_by(&:updated_at).reverse
  end

  # GET /games/1 as JS
  def show
    # Show game settings while user is not owner
  end

  # GET /games/1/edit as JS
  def edit
    # Edit game settings while user IS owner
  end

  # GET: Show the board to play the game
  def play
    set_game

    # check on turns too_late
    play_turn = Turn.find_by game_id: params[:id], state: 'play'
    return unless play_turn

    js_seconds = params[:game_js_time].to_i / 1000
    # turn is too late
    while play_turn && Time.at(js_seconds) > play_turn.started + @game.play_time
      logger.info 'game / turn is too late: ' + @game.id.to_s + ' / ' + play_turn.id.to_s
      logger.info '== game_js_time: ' + js_seconds.to_s
      logger.info '== play_turn.started: ' + play_turn.started.to_s
      play_turn.ended = Time.at(js_seconds + @game.play_time)
      play_turn.end_letters = play_turn.start_letters
      play_turn.expiring
      play_turn.save
      play_turn = @game.goto_next(play_turn)
    end
  end

  # PATCH/PUT /games/1 as JS
  def update
    # Update game settings
    return unless @game.update(game_params)

    flash.now[:notice] = (t :model_updated, name: @game.name, model: Game.model_name.human)
    flash.keep

    # saved, start or to index
    start_game
  end

  # Only JS
  def new
    @game = Game.new
  end

  # POST /games.js
  def create
    @game = Game.new(game_params)
    @game.owner = current_user
    return unless @game.save

    flash.now[:notice] = (t :model_created, name: @game.name, model: Game.model_name.human)
    flash.keep

    # saved, start or to index
    start_game
  end

  def destroy
    name = @game.name
    @game.destroy
    redirect_to games_path, notice: (t :model_deleted, name: name, model: Game.model_name.human)
  end

  private #===============================================================

  # Use callbacks to share layer_1 setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
    @turn = Turn.where(game_id: @game.id, user_id: current_user.id).last
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def game_params
    params[:game][:user_ids].reject!(&:empty?)
    params.require(:game).permit(:name, :board_id, :letter_set_id, :words_list_id, :extra_words_lists,
                                 :play_time_days, :play_time_hours, :play_time_minutes, :js_time, user_ids: [])
  end

  # make game playable for accepters (play btn = disabled)
  def start_game
    @game.start_now!

    # current_user = gamer? -> accept!
    if @game.users.include?(current_user)
      gamer = Gamer.find_by(game_id: @game.id, user_id: current_user.id)
      gamer.accept!
      # @turn = Turn.find_by(game_id: @game.id, user_id: current_user.id)
    end

    # check play now (one player)
    started = @game.check_play_now(params[:game][:js_time].to_i)

    # saved, start immediately
    if params[:commit] == (t :btn_start)
      redirect_to action: :play, id: @game.id, js_time: params[:game][:js_time], status: 303 # See Other

    # only saved, back to index
    else
      redirect_to action: :index
    end
  end
end
