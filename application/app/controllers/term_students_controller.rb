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
    @term_student = TermStudent.joins(:student).select(:id, :name, :school_grade, :vacancy_status).find_by(id: params[:term_student_id])
    @student_vacancies = @term_student.student_vacancies.joins(:timetable).select(:id, :date_index, :period_index, :is_vacant)
  end

  def schedule
    @term_student = TermStudent.find_by(id: params[:term_student_id])
    @tutorial_pieces = TutorialPiece.joins(
      tutorial_contract: [
        term_student: [],
        term_tutorial: [:tutorial],
        term_teacher: [:teacher]
      ],
      seat: :timetable,
    ).select(
      :date_index,
      :period_index,
      'tutorials.name AS tutorial_name',
      'teachers.name AS teacher_name',
    ).where('term_students.id': params[:term_student_id])

    @timetables = Timetable.left_joins(
      term_group: [:group_contracts, :group],
      student_vacancies: [],
    ).where(
      term_id: @term.id,
      'student_vacancies.term_student_id': params[:term_student_id],
      'group_contracts.term_student_id': nil,
    ).or(
      Timetable.where(
        term_id: @term.id,
        'student_vacancies.term_student_id': params[:term_student_id],
        'group_contracts.term_student_id': params[:term_student_id],
      ),
    ).select(
      :date_index,
      :period_index,
      :term_group_id,
      :is_closed,
      'student_vacancies.is_vacant',
      'group_contracts.is_contracted',
      'groups.name AS group_name',
    )
    respond_to do |format|
      format.html
      #format.pdf do
      #  pdf = StudentSchedule.new(@term, @term_student, @pieces, @student_requests).render
      #  send_data pdf,
      #            filename: "#{@term.name}予定表#{@term_student.student.name}.pdf",
      #            type: 'application/pdf',
      #            disposition: 'inline'
      #end
    end
  end

  private

  def create_params
    params.require(:term_student).permit(:term_id, :student_id, :school_grade)
  end

  def update_params
    params.require(:term_student).permit(:vacancy_status)
  end
end
