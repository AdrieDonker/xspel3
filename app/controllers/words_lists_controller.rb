class WordsListsController < ApplicationController
  before_action :admin_only, except: :show
  before_action :set_words_list, only: [:show, :edit, :update, :destroy]

  def index
    @words_lists = WordsList.order :name, :group
  end

  def show
  end

  def new
    @words_list = WordsList.new
  end

  def edit
  end

  def create
    @words_list = WordsList.new(words_list_params)
    if @words_list.save
      redirect_to words_lists_path, notice: (t :model_created, name: @words_list.name, model: WordsList.model_name.human)
    else
      render :new
    end
  end

  def update
    if @words_list.update_attributes(words_list_params)

      # Name changed?
      if @words_list.name != params[:old_name]
        WordsList.where(name: params[:old_name]).update_all(name: @words_list.name)
      end
      redirect_to words_lists_path, notice: (t :model_updated, name: @words_list.name, model: WordsList.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    name = @words_list.name
    @words_list.destroy
    redirect_to words_lists_path, notice: (t :model_deleted, name: name, model: WordsList.model_name.human)
  end

  private

  def words_list_params
    params.require(:words_list).permit(:name, :group, :description, :words_spaced)
  end

  def set_words_list
    @words_list = WordsList.find(params[:id])
  end

  def admin_only
    unless current_user.admin?
      redirect_back fallback_location: root_path, alert: (t :no_access)
    end
  end
end
