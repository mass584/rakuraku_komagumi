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
    @term_teacher = TermTeacher.joins(:teacher).select(:id, :name, :vacancy_status).find_by(id: params[:term_teacher_id])
    @teacher_vacancies = @term_teacher.teacher_vacancies.joins(:timetable).select(:id, :date_index, :period_index, :is_vacant)
  end

  def schedule
    @term_teacher = TermTeacher.find_by(id: params[:term_teacher_id])
    @tutorial_pieces = TutorialPiece.joins(
      tutorial_contract: [
        term_student: [:student],
        term_tutorial: [:tutorial],
        term_teacher: []
      ],
      seat: :timetable,
    ).select(
      :date_index,
      :period_index,
      'students.name AS student_name',
      'tutorials.name AS tutorial_name',
    ).where('term_teachers.id': params[:term_teacher_id])
    @timetables = Timetable.left_joins(
      term_group: [:group],
      teacher_vacancies: [],
    ).where(
      term_id: @term.id,
      'teacher_vacancies.term_teacher_id': params[:term_teacher_id],
    ).select(
      :date_index,
      :period_index,
      :term_group_id,
      :is_closed,
      'teacher_vacancies.is_vacant',
      'term_groups.term_teacher_id',
      'groups.name AS group_name',
    )
    respond_to do |format|
      format.html
      #format.pdf do
      #  pdf = TeacherSchedule.new(@term, @term_teacher, @pieces, @teacher_requests).render
      #  send_data pdf,
      #            filename: "#{@term.name}予定表#{@term_teacher.teacher.name}.pdf",
      #            type: 'application/pdf',
      #            disposition: 'inline'
      #end
    end
  end

  private

  def create_params
    params.require(:term_teacher).permit(:term_id, :teacher_id)
  end

  def update_params
    params.require(:term_teacher).permit(:vacancy_status, :row_order_position)
  end
end
