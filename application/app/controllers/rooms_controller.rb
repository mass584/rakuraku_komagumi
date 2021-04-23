class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!

  def index
    @rooms = Room.ordered
  end

  def create
    @room = Room.new(create_params)
    respond_to do |format|
      if @room.save
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def update
    @room = Room.find_by(id: params[:id])
    respond_to do |format|
      if @room.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  private

  def create_params
    params.require(:room).permit(:name)
  end

  def update_params
    params.require(:room).permit(:name)
  end
end
