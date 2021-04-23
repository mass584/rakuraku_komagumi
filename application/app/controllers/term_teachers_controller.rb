class TermTeachersController < ApplicationController
  INDEX_PAGE_SIZE = 10

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = INDEX_PAGE_SIZE
    @term_teachers = @term.term_teachers.ordered.pagenated(@page, @page_size)
    @term_teachers_count = @term.term_teachers.count
  end

  def create
    @term_teacher = TermTeacher.new(create_params)
    respond_to do |format|
      if @term_teacher.save
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def update
    record = TermTeacher.find_by(id: params[:id])
    respond_to do |format|
      if record.update(update_params)
        format.js { @success = true }
        format.json { render json: { term_teacher: record } }
      else
        format.js { @success = false }
        format.json { render json: { term_teacher: record } }
      end
    end
  end

  def vacancy
    @term_teacher = TermTeacher.named.find_by(id: params[:term_teacher_id])
    @teacher_vacancies = @term_teacher.teacher_vacancies.indexed
  end

  def schedule
    @term_teacher = TermTeacher.find_by(id: params[:term_teacher_id])
    @tutorial_pieces = TutorialPiece.indexed_and_named.where('term_teachers.id': params[:term_teacher_id])
    @timetables = Timetable.with_group.with_teacher_vacancies.where(
      term_id: @term.id,
      'teacher_vacancies.term_teacher_id': params[:term_teacher_id],
    )
  end

  private

  def create_params
    params.require(:term_teacher).permit(:term_id, :teacher_id)
  end

  def update_params
    params.require(:term_teacher).permit(:vacancy_status, :row_order_position)
  end
end
