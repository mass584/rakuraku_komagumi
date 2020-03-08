class StudentSchedulemasterMappingController < ApplicationController
  before_action :check_login
  before_action :check_schedulemaster

  def create
    student = Student.find_by(id: create_params[:student_id])
    respond_to do |format|
      if StudentSchedulemasterMapping.additional_create(student, @schedulemaster)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  private

  def create_params
    params.require(:student_schedulemaster_mapping).permit(:student_id)
  end
end
