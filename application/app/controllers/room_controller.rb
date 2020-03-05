class RoomController < ApplicationController
  before_action :check_login, only: [:edit, :update]

  def edit
  end

  def update
    @status = @room.update(update_params)
  end

  def login
  end

  def auth
    room = Room.find_by(email: params[:email])
    if room&.authenticate(params[:password])
      reset_session
      session[:room_id] = room.id
      redirect_to params[:referer] || '/'
    else
      flash[:email] = params[:email]
      flash[:referer] = params[:referer]
      flash[:error] = 'IDが存在しないか、パスワードが間違えています'
      redirect_to controller: :room, action: :login
    end
  end

  def logout
    reset_session
    redirect_to controller: :room, action: :login
  end

  private

  def update_params
    params.require(:room).permit(:name, :email, :tel, :zip, :address)
  end
end
