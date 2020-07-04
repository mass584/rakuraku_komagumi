class RoomController < ApplicationController
  before_action :room_signed_in?

  def update
    @status = current_room.update(update_params)
  end

  private

  def update_params
    params.require(:room).permit(:name, :email, :tel, :zip, :address)
  end
end
