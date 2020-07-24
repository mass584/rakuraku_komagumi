class TeacherSubjectController < ApplicationController
  before_action :authenticate_room!

  def create
    record = TeacherSubject.new(create_params)
    if record.save
      render json: record.to_json, status: :created
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  def destroy
    record = TeacherSubject.find_by(id: params[:id])
    if record.destroy
      render json: {}, status: :no_content
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:teacher_subject).permit(:teacher_id, :subject_id)
  end
end
