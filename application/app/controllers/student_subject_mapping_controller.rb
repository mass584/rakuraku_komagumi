class StudentSubjectMappingController < ApplicationController
  def create
    StudentSubjectMapping.new(
      student_id: params[:student_id],
      subject_id: params[:subject_id],
    ).save
    render(json: {}, status: :no_content) && return
  end

  def delete
    StudentSubjectMapping.find_by(
      student_id: params[:student_id],
      subject_id: params[:subject_id],
    ).destroy
    render(json: {}, status: :no_content) && return
  end
end
