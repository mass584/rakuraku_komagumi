class RoomController < ApplicationController
  include RoomStore
  before_action :check_logined
  helper_method :room

  def edit
  end

  def update
    @status = if room.update(room_params)
                'success'
              else
                'fail'
              end
  end

  private

  def room_params
    params.require(:room).permit(:roomname, :zip, :address, :mail, :tel, :fax)
  end
end
