class TeacherSchedulemasterMappingController < ApplicationController
  before_action :check_login
  before_action :check_schedulemaster

  def create
    teacher = Teacher.find_by(id: create_params[:teacher_id])
    respond_to do |format|
      if TeacherSchedulemasterMapping.additional_create(teacher, @schedulemaster)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  private

  def create_params
    params.require(:teacher_schedulemaster_mapping).permit(:teacher_id)
  end
end
