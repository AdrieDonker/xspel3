class LetterSetsController < ApplicationController
  before_action :set_letter_set, only: [:show, :edit, :update, :destroy]

  # GET /letter_sets
  # GET /letter_sets.json
  def index
    @letter_sets = LetterSet.all
  end

  # GET /letter_sets/1
  # GET /letter_sets/1.json
  def show
  end

  # GET /letter_sets/new
  def new
    @letter_set = LetterSet.new
  end

  # GET /letter_sets/1/edit
  def edit
  end

  # POST /letter_sets
  # POST /letter_sets.json
  def create
    @letter_set = LetterSet.new(letter_set_params)

    respond_to do |format|
      if @letter_set.save
        format.html { redirect_to @letter_set, notice: 'Letter set was successfully created.' }
        format.json { render :show, status: :created, location: @letter_set }
      else
        format.html { render :new }
        format.json { render json: @letter_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /letter_sets/1
  # PATCH/PUT /letter_sets/1.json
  def update
    respond_to do |format|
      if @letter_set.update(letter_set_params)
        format.html { redirect_to @letter_set, notice: 'Letter set was successfully updated.' }
        format.json { render :show, status: :ok, location: @letter_set }
      else
        format.html { render :edit }
        format.json { render json: @letter_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /letter_sets/1
  # DELETE /letter_sets/1.json
  def destroy
    @letter_set.destroy
    respond_to do |format|
      format.html { redirect_to letter_sets_url, notice: 'Letter set was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_letter_set
      @letter_set = LetterSet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def letter_set_params
      params.require(:letter_set).permit(:name, :letter_amount_points)
    end
end
