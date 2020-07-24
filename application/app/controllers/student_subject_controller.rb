class StudentSubjectController < ApplicationController
  before_action :authenticate_room!

  def create
    record = StudentSubject.new(create_params)
    if record.save
      render json: record.to_json, status: :created
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  def destroy
    record = StudentSubject.find_by(id: params[:id])
    if record.destroy
      render json: {}, status: :no_content
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:student_subject).permit(:student_id, :subject_id)
  end
end
