class TeacherRequestController < ApplicationController
  before_action :room_signed_in?
  before_action :term_selected?

  def create
    record = TeacherRequest.new(create_params)
    if record.save
      render json: record.to_json, status: :created
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  def destroy
    record = TeacherRequest.find(params[:id])
    if record.destroy
      render json: {}, status: :no_content
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:teacher_request).permit(
      :teacher_term_id,
      :timetable_id,
    ).merge(
      term_id: @term.id,
    )
  end
end
