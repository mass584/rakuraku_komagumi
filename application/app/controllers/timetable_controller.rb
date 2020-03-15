class TimetableController < ApplicationController
  before_action :check_login
  before_action :check_schedulemaster
  before_action :check_schedulemaster_batch_status

  def index
    @timetablemasters = Timetablemaster.get_timetablemasters(@schedulemaster)
    @timetables = Timetable.get_timetables(@schedulemaster)
  end

  def update_timetable
    timetable = Timetable.find(params[:id])
    if timetable.update(update_timetable_params)
      render json: {}, status: :no_content
    else
      render json: { message: timetable.errors.full_messages }, status: :bad_request
    end
  end

  def update_timetablemaster
    timetablemaster = Timetablemaster.find(params[:id])
    if timetablemaster.update(update_timetable_master_params)
      render json: {}, status: :no_content
    else
      render json: { message: timetablemaster.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_timetable_params
    params.require(:timetable).permit(:status)
  end

  def update_timetable_master_params
    params.require(:timetable).permit(:begin_at, :end_at)
  end
end
