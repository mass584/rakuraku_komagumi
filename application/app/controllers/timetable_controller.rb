class TimetableController < ApplicationController
  before_action :room_signed_in?
  before_action :term_selected?

  def index
    @begin_end_times = BeginEndTime.get_begin_end_times(@term)
    @timetables = Timetable.get_timetables(@term)
  end

  def update
    timetable = Timetable.find(params[:id])
    if timetable.update(update_params)
      render json: {}, status: :no_content
    else
      render json: { message: timetable.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:timetable).permit(:status)
  end
end
