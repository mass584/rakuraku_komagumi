class TeacherSubjectMappingController < ApplicationController
  def create
    TeacherSubjectMapping.new(
      subject_id: params[:subject_id],
      teacher_id: params[:teacher_id],
    ).save
    render(json: {}, status: :no_content) && return
  end

  def delete
    TeacherSubjectMapping.find_by(
      subject_id: params[:subject_id],
      teacher_id: params[:teacher_id],
    ).destroy
    render(json: {}, status: :no_content) && return
  end
end
