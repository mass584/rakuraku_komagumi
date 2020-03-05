class TimetableController < ApplicationController
  require 'time'
  before_action :check_login
  before_action :check_schedulemaster
  before_action :check_schedulemaster_batch_status

  ERROR_MSG_CHANGE_TIMETABLE = '既に授業が割り当てられているので、変更できません。'.freeze

  def timetables
    return @timetables if defined? @timetables

    @timetables = Timetable.get_timetables(@schedulemaster)
  end
  helper_method :timetables

  def timetablemasters
    return @timetablemasters if defined? @timetablemasters

    @timetablemasters = Timetablemaster.get_timetablemasters(@schedulemaster)
  end
  helper_method :timetablemasters

  def index
  end

  def update
    timetable = Timetable.find(params[:id])
    new_status = params[:status]
    result = validate(timetable, new_status, @schedulemaster)
    if result[:status] == 204 && timetable.update(status: new_status)
      render json: {}, status: :no_content
    else
      render json: { message: result[:message] }, status: :bad_request
    end
  end

  def update_master
    timetablemaster = Timetablemaster.find(params[:id])
    begintime = DateTime.parse("2000/01/01 #{params[:begintime]}")
    endtime = DateTime.parse("2000/01/01 #{params[:endtime]}")
    respond_to do |_format|
      if timetablemaster.update(begintime: begintime, endtime: endtime)
        render(json: {}, status: :no_content) && return
      else
        render(json: { message: timetablemaster.errors.full_messages }, status: :bad_request) && return
      end
    end
  end

  private

  def validate(timetable, new_status, @schedulemaster)
    if @schedulemaster.schedules.where(timetable_id: timetable.id).count.positive?
      { status: 400, message: ERROR_MSG_CHANGE_TIMETABLE }
    else
      { status: 204 }
    end
  end
end
