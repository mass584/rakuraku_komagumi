class TeacherTermController < ApplicationController
  before_action :room_signed_in?
  before_action :term_selected?

  def index
    @teacher_terms = TeacherTerm.get_teacher_terms(@term)
  end

  def show
    @teacher_term = TeacherTerm.find(params[:id])
    @timetables = Timetable.get_timetables(@term)
    @teacher_requests = TeacherRequest.get_teacher_requests(@teacher_term, @term)
  end

  def create
    @teacher_term = TeacherTerm.new(create_params)
    if @teacher_term.save
      render 'teacher_term/create'
    end
  end

  def update
    record = TeacherTerm.find(params[:id])
    if record.update(update_params)
      render json: {}, status: :no_content
    else
      render json: {}, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:teacher_term).permit(
      :teacher_id,
    ).merge({
      term_id: @term.id,
      status: 0,
    })
  end

  def update_params
    params.require(:teacher_term).permit(:status)
  end
end
