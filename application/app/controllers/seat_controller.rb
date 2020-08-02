class SeatController < ApplicationController
  before_action :authenticate_room!
  before_action :term_selected?

  def index
    @records = Seat.includes(
      timetable: [:student_requests, :teacher_requests],
      teacher_term: [:teacher],
    ).where(term_id: @term.id)
    render 'index', formats: :json, handlers: 'jbuilder'
  end

  def update
    record = Seat.find(params[:id])
    if record.update!(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:seat).permit(:teacher_term_id)
  end
end
