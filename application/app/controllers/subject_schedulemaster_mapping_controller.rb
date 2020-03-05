class SubjectSchedulemasterMappingController < ApplicationController
  include RoomStore
  include SchedulemasterStore
  include Mapping
  before_action :check_logined
  before_action :check_schedulemaster
  helper_method :room
  helper_method :schedulemaster

  ERROR_MSG_CHANGE_GROUP_TANNIN = '個別授業が１つでも割り当てられていると、集団授業の担任を変更することはできません。'.freeze

  def new
    @subject_schedulemaster_mapping = SubjectSchedulemasterMapping.new
  end

  def create
    subject_id = params[:subject_schedulemaster_mapping][:subject_id]
    subject = Subject.find(subject_id)
    respond_to do |format|
      if associate_subject_to_schedulemaster(subject_id, schedulemaster.id)
        Classnumber.bulk_create_each_subject(subject, schedulemaster)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def update
    schedulemaster = Schedulemaster.find(session[:schedulemaster_id])
    subject_schedulemaster_mapping =
      schedulemaster.subject_schedulemaster_mappings.find_by(subject_id: params[:subject_id])
    result = validate(schedulemaster)
    if result[:status] == 204
      subject_schedulemaster_mapping.update(teacher_id: params[:teacher_id].to_i)
      render json: {}, status: :no_content
    else
      render json: { message: result[:message] }, status: :bad_request
    end
  end

  private

  def validate(schedulemaster)
    if schedulemaster.schedules.where.not(timetable_id: 0).count.positive?
      { status: 400, message: ERROR_MSG_CHANGE_GROUP_TANNIN }
    else
      { status: 204 }
    end
  end
end
