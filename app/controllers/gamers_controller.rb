class GamersController < ApplicationController
  before_action :set_gamer, only: [:show, :edit, :update, :destroy]

  # GET /gamers
  # GET /gamers.json
  def index
    @gamers = Gamer.all
  end

  # GET /gamers/1
  # GET /gamers/1.json
  def show
  end

  # GET /gamers/new
  def new
    @gamer = Gamer.new
  end

  # GET /gamers/1/edit
  def edit
  end

  # POST /gamers
  # POST /gamers.json
  def create
    @gamer = Gamer.new(gamer_params)

    respond_to do |format|
      if @gamer.save
        format.html { redirect_to @gamer, notice: 'Gamer was successfully created.' }
        format.json { render :show, status: :created, location: @gamer }
      else
        format.html { render :new }
        format.json { render json: @gamer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gamers/1
  # PATCH/PUT /gamers/1.json
  def update
    respond_to do |format|
      if @gamer.update(gamer_params)
        format.html { redirect_to @gamer, notice: 'Gamer was successfully updated.' }
        format.json { render :show, status: :ok, location: @gamer }
      else
        format.html { render :edit }
        format.json { render json: @gamer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gamers/1
  # DELETE /gamers/1.json
  def destroy
    @gamer.destroy
    respond_to do |format|
      format.html { redirect_to gamers_url, notice: 'Gamer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gamer
      @gamer = Gamer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gamer_params
      params.require(:gamer).permit(:game_id, :user_id, :sequence_nbr, :score, :state, :position)
    end
end
