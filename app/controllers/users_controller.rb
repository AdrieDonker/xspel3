class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only, :except => :show
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def edit
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => (t :user_updated)
    else
      render :edit
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to users_path, :notice => (t :user_deleted)
  end

  private

  def admin_only
    unless current_user.admin?
      redirect_to :back, :alert => (t :no_access)
    end
  end

  def secure_params
    params.require(:user).permit(:name, :role, :locale, :email)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
