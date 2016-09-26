class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games.js
  def index
    @games = []
    # Games of owner and as Gamer
    if current_user
      @games = (current_user.games.to_a + Game.where(owner_id: current_user.id).to_a).uniq.sort_by{ |x| x.updated_at }.reverse
    end
  end

  # GET /games/1 as JS
  def show
    # Show game settings while user is not owner
  end

  # GET /games/1/edit as JS
  def edit
    # Edit game settings while user IS owner
  end
  
  # GET /games/play
  def play
    set_game
    # Show the board to play the game
    
  end

  # PATCH/PUT /games/1 as JS
  def update
    
    # Update game settings
    params[:game][:user_ids].reject!(&:empty?)
    if @game.update(game_params)
      
      # Saved, start immediately
      if params[:commit] == (t :btn_start)
        @game.start_now rescue nil

        # Invites should have been send
        if @game.playable?
          @game.save
          
          # Open the game (redirect)
          flash.now[:notice] = "Ja, spelen maar!"
          flash.keep
          redirect_to action: :play
          
        # else error with invites, from model
        end
        
      # Only saved, back to index
      else
        flash.now[:notice] = (t :model_updated, name: @game.name, model: Game.model_name.human)
        flash.keep
        redirect_to action: :index
      end
    end
  end
  
  # Only JS
  def new
    @game = Game.new
  end

  # POST /games.js
  def create
    params[:game][:user_ids].reject!(&:empty?)
    @game = Game.new(game_params)
    @game.owner = current_user
    if @game.save
      flash.now[:notice] = (t :model_created, name: @game.name, model: Game.model_name.human)
      flash.keep

      # Start immediately
      if params[:commit] == (t :btn_start)
        
        if @game.may_start_now?
          @game.start_now
        
          # Invites send?
          if @game.playable?
            flash.now[:notice] = "Ja, spelen maar!"
            flash.keep
            redirect_to action: :index
          end
        end
      end
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
