class BoardsController < ApplicationController
  before_action :set_board, only: [:show, :edit, :update, :destroy]

  def index
    @boards = Board.all
    if @boards.size == 0
      Board.create_standard_board
    end
    @boards = Board.all
  end

  def show
  end

  def new
    @board = Board.new
  end

  def edit
  end

  def create
    @board = Board.new(board_params)
    if @board.save
      redirect_to boards_path, notice: (t :model_created, name: @board.name, model: Board.model_name.human)
    else
      render :new
    end
  end

    def update
    if @board.update_attributes(board_params)
      redirect_to boards_path, :notice => (t :model_updated, name: @board.name, model: Board.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    name = @board.name
    @board.destroy
    redirect_to boards_path, :notice => (t :model_deleted, name: name, model: Board.model_name.human)
  end

  private
  
  def board_params
    params.require(:board).permit(:name, :layout)
  end
  
  def set_board
    @board = Board.find(params[:id])
  end

  def admin_only
    unless current_user.admin?
      redirect_back fallback_location: root_path, alert: (t :no_access)
    end
  end

end
