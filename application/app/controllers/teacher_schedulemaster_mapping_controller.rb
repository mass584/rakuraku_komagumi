class TeacherSchedulemasterMappingController < ApplicationController
  include RoomStore
  include SchedulemasterStore
  include Mapping
  before_action :check_logined
  before_action :check_schedulemaster
  helper_method :room
  helper_method :schedulemaster

  def new
    @teacher_schedulemaster_mapping = TeacherSchedulemasterMapping.new
  end

  def create
    teacher_id = params[:teacher_schedulemaster_mapping][:teacher_id]
    respond_to do |format|
      if associate_teacher_to_schedulemaster(teacher_id, schedulemaster.id)
        Teacherrequestmaster.create(
          teacher_id: teacher_id,
          schedulemaster_id: schedulemaster.id,
          status: 0,
        )
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end
end
