class StudentTermController < ApplicationController
  before_action :room_signed_in?
  before_action :term_selected?

  def index
    @student_terms = StudentTerm.get_student_terms(@term)
  end

  def show
    @student_term = StudentTerm.find(params[:id])
    @timetables = Timetable.get_timetables(@term)
    @student_requests = StudentRequest.get_student_requests(@student_term, @term)
  end

  def create
    @student_term = StudentTerm.new(create_params)
    if @student_term.save_with_contract
      render 'student_term/create'
    end
  end

  def update
    record = StudentTerm.find(params[:id])
    if record.update(update_params)
      render json: {}, status: :no_content
    else
      render json: {}, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:student_term).permit(
      :student_id,
    ).merge({
      term_id: @term.id,
      status: 0,
    })
  end

  def update_params
    params.require(:student_term).permit(:status)
  end
end
