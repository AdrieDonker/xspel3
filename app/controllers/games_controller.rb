class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games.js
  def index
    @games = []
    # Games of Gamer and owner
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
  
  # GET: Show the board to play the game
  def play
    set_game
    @turn = @game.turns.where({user_id: current_user.id}).last
  end

  # PATCH/PUT /games/1 as JS
  def update
    
    # Update game settings
    params[:game][:user_ids].reject!(&:empty?)
    if @game.update(game_params)
      
      # Saved, start immediately
      if params[:commit] == (t :btn_start)
        @game.start_now rescue nil    # send invites

        # Invites should have been send
        if @game.playable?
          @game.save
          
          # current_user = gamer?
          if @game.users.include?(current_user)
            @game.create_turn(current_user)
          end
          
          # Open the game (redirect)
          redirect_to action: :play, status: 303 #See Other
          
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

      # Saved, start immediately
      if params[:commit] == (t :btn_start)
        @game.start_now rescue nil    # send invites

        # Invites should have been send
        if @game.playable?
          @game.save
          
          # current_user = gamer?
          if @game.users.include?(current_user)
            @game.create_turn(current_user)
          end
          
          # Open the game (redirect)
          redirect_to action: :play, id: @game.id, status: 303 #See Other
          
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

  def destroy
    name = @game.name
    @game.destroy
    redirect_to games_path, :notice => (t :model_deleted, name: name, model: Game.model_name.human)
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
