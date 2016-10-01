class LetterSetsController < ApplicationController
  before_action :admin_only, except: :show
  before_action :set_letter_set, only: [:show, :edit, :update, :destroy]

  def index
    @letter_sets = LetterSet.all
    if @letter_sets.size == 0
      LetterSet.create_standard_letter_sets
    end
    @letter_sets = LetterSet.all
  end

  def show
  end

  def new
    @letter_set = LetterSet.new
  end

  def edit
  end

  def create
    @letter_set = LetterSet.new(letter_set_params)
    if @letter_set.save
      redirect_to letter_sets_path, notice: (t :model_created, name: @letter_set.name, model: LetterSet.model_name.human)
    else
      render :new
    end
  end

  def update
    if @letter_set.update_attributes(letter_set_params)
      redirect_to letter_sets_path, :notice => (t :model_updated, name: @letter_set.name, model: LetterSet.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    name = @letter_set.name
    @letter_set.destroy
    redirect_to letter_sets_path, :notice => (t :model_deleted, name: name, model: LetterSet.model_name.human)
  end

  private
  
  def letter_set_params
    params.require(:letter_set).permit(:name, :letter_amount_points)
  end
  
  def set_letter_set
    @letter_set = LetterSet.find(params[:id])
  end

  def admin_only
    unless current_user.admin?
      redirect_back fallback_location: root_path, alert: (t :no_access)
    end
  end

end
