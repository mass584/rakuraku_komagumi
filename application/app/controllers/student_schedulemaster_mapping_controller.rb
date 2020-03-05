class StudentSchedulemasterMappingController < ApplicationController
  include RoomStore
  include SchedulemasterStore
  include Mapping
  before_action :check_logined
  before_action :check_schedulemaster
  helper_method :room
  helper_method :schedulemaster

  def new
    @student_schedulemaster_mapping = StudentSchedulemasterMapping.new
  end

  def create
    student_id = params[:student_schedulemaster_mapping][:student_id]
    student = Student.find(student_id)
    respond_to do |format|
      if associate_student_to_schedulemaster(student_id, schedulemaster.id)
        Studentrequestmaster.create(
          schedulemaster_id: schedulemaster.id,
          student_id: student_id,
          status: 0,
        )
        Classnumber.bulk_create_each_student(student, schedulemaster)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end
end
