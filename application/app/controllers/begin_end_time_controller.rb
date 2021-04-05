class BeginEndTimeController < ApplicationController
  before_action :authenticate_user!
  before_action :term_selected?

  def update
    record = BeginEndTime.find(params[:id])
    if record.update(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:timetable).permit(:begin_at, :end_at)
  end
end
