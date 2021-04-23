class TermStudentsController < ApplicationController
  INDEX_PAGE_SIZE = 10

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = INDEX_PAGE_SIZE
    @term_students = @term.term_students.ordered.pagenated(@page, @page_size)
    @term_students_count = @term.term_students.count
  end

  def create
    @term_student = TermStudent.new(create_params)
    respond_to do |format|
      if @term_student.save
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def update
    record = TermStudent.find_by(id: params[:id])
    respond_to do |format|
      if record.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def vacancy
    @term_student = TermStudent.named.find_by(id: params[:term_student_id])
    @student_vacancies = @term_student.student_vacancies.indexed
  end

  def schedule
    @term_student = TermStudent.find_by(id: params[:term_student_id])
    @tutorial_pieces = TutorialPiece.indexed_and_named.where(
      'term_students.id': params[:term_student_id],
    )
    @timetables = Timetable.with_group.with_group_contracts.with_student_vacancies.where(
      term_id: @term.id,
      'student_vacancies.term_student_id': params[:term_student_id],
      'group_contracts.term_student_id': nil,
    ).or(
      Timetable.where(
        term_id: @term.id,
        'student_vacancies.term_student_id': params[:term_student_id],
        'group_contracts.term_student_id': params[:term_student_id],
      ),
    )
  end

  private

  def create_params
    params.require(:term_student).permit(:term_id, :student_id, :school_grade)
  end

  def update_params
    params.require(:term_student).permit(:vacancy_status)
  end
end
