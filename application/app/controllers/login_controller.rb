class LoginController < ApplicationController
  def index
  end

  def auth
    room = Room.find_by(login_id: params[:login_id])
    if room&.authenticate(params[:password])
      reset_session
      session[:login_id] = room.login_id
      if params[:referer]
        redirect_to params[:referer]
      else
        redirect_to '/'
      end
    else
      flash[:login_id] = params[:login_id]
      flash[:referer] = params[:referer]
      flash[:error] = 'IDが存在しないか、パスワードが間違えています'
      redirect_to controller: :login, action: :index
    end
  end

  def logout
    reset_session
    redirect_to controller: :login, action: :index
  end
end
