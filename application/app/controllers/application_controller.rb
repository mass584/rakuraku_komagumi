class ApplicationController < ActionController::Base
  private

  def check_logined
    if !session[:login_id]
      flash[:referer] = request.fullpath
      redirect_to controller: :login, action: :index
    end
    begin
      Room.find_by(login_id: session[:login_id])
    rescue ActiveRecord::RecordNotFound
      reset_session
      redirect_to controller: :login, action: :index
    end
  end

  def check_schedulemaster
    if !session[:schedulemaster_id]
      redirect_to controller: :schedulemaster, action: :index
    end
    begin
      schedulemaster = Schedulemaster.find(session[:schedulemaster_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to controller: :schedulemaster, action: :index
    end
    if schedulemaster.calculation_status == 1
      redirect_to controller: :schedulemaster, action: :index
    end
  end
end
