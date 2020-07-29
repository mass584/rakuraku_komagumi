class SeatController < ApplicationController
  before_action :authenticate_room!
  before_action :term_selected?

  def update
    record = Seat.find(params[:id])
    if record.update!(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:seat).permit(:teacher_term_id)
  end
end
