class UsersController < ApplicationController
  before_action :admin_only, except: :show
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.includes(:language)
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: (t :model_created, name: @user.name, model: User.model_name.human)
    else
      render :new
    end
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to users_path, notice: (t :model_updated, name: @user.name, model: User.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    name = @user.name
    @user.destroy
    redirect_to users_path, notice: (t :model_deleted, name: name, model: User.model_name.human)
  end

  private

  def user_params
    params[:user][:knows_users].reject!(&:empty?)
    params.require(:user).permit(:name, :role, :locale, :time_zone, :email, knows_users: [])
  end

  def set_user
    @user = User.find(params[:id])
  end

  def admin_only
    unless current_user.admin?
      redirect_back fallback_location: root_path, alert: (t :no_access)
    end
  end
end
