module RoomStore
  def room
    return @room if defined? @room

    @room = Room.find_by(login_id: session[:login_id])
  end
end
