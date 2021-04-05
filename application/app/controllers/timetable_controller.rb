class TimetableController < ApplicationController
  before_action :authenticate_user!
  before_action :term_selected?

  def index
    @begin_end_times = BeginEndTime.get_begin_end_times(@term)
    @timetables = Timetable.get_timetables(@term)
    @week = @term.week(params[:week].to_i)
  end

  def update
    record = Timetable.find(params[:id])
    if record.update(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:timetable).permit(:is_closed)
  end
end
