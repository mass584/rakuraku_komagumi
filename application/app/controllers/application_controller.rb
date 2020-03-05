class ApplicationController < ActionController::Base
  private

  def check_login
    if !session[:room_id]
      flash[:referer] = request.fullpath
      redirect_to controller: :room, action: :login
    else
      @room = Room.find(session[:room_id])
    end
  end

  def check_schedulemaster
    if !session[:schedulemaster_id]
      redirect_to controller: :schedulemaster, action: :index
    else
      @schedulemaster = Schedulemaster.find(session[:schedulemaster_id])
    end
  end

  def check_schedulemaster_batch_status
    if @schedulemaster.batch_status == 1
      redirect_to controller: :schedulemaster, action: :index
    end
  end
end
