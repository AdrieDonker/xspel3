class SettingsController < ApplicationController
  before_action :set_setting, only: [:show, :edit, :update, :destroy]

  def index
    @settings = Setting.all
  end

  def show
  end

  def new
    @setting = Setting.new
  end

  def edit
  end

  def create
    @setting = Setting.new(setting_params)
    if @setting.save
      redirect_to settings_path, notice: (t :model_created, name: @setting.name, model: Setting.model_name.human)
    else
      render :new
    end
  end

    def update
    if @setting.update_attributes(setting_params)
      redirect_to settings_path, :notice => (t :model_updated, name: @setting.name, model: Setting.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    name = @setting.name
    @setting.destroy
    redirect_to settings_path, :notice => (t :model_deleted, name: name, model: Setting.model_name.human)
  end

  private
  
  def set_setting
    @setting = Setting.find(params[:id])
  end

  def setting_params
    params.require(:setting).permit(:name, :max_invite_hours, :max_play_hours, :extra_on_bingo)
  end
  
  def admin_only
    unless current_user.admin?
      redirect_back fallback_location: root_path, alert: (t :no_access)
    end
  end

end
