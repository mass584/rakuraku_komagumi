class ClassnumberController < ApplicationController
  before_action :check_login
  before_action :check_schedulemaster
  before_action :check_schedulemaster_batch_status

  def index
    @classnumbers = Classnumber.get_classnumbers(@schedulemaster)
    puts @classnumbers
  end

  def update
    classnumber = Classnumber.find(params[:id])
    if classnumber.update(update_params)
      render json: {}, status: :no_content
    else
      render json: { message: classnumber.errors.full_messages }, status: :bad_request
    end
  end

  def destroy
    classnumber = Classnumber.find(params[:id])
    if classnumber.update(teacher_id: nil, number: 0)
      render(json: {}, status: :no_content)
    else
      render json: { message: classnumber.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:classnumber).permit(
      :teacher_id,
      :number
    )
  end
end
