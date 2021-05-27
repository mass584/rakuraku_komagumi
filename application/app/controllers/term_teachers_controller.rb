class TermTeachersController < ApplicationController
  INDEX_PAGE_SIZE = 10

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @term_teachers_count = @term.term_teachers.count
    @current_page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = sanitize_integer_query_param(params[:page_size]) || 10
    @term_teachers = @term.term_teachers.ordered.pagenated(@page, @page_size)
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
    @teacher_vacancies = @term_teacher.teacher_vacancies.with_timetable
  end

  def schedule
    @term_teacher = TermTeacher.find_by(id: params[:term_teacher_id])
    @tutorial_pieces = TutorialPiece.with_tutorial_contract.with_seat_and_timetable.where(
      'term_teachers.id': params[:term_teacher_id],
    )
    @term_groups = Timetable.with_term_group_term_teachers.where(
      term_id: @term.id,
      'term_group_term_teachers.term_teacher_id': params[:term_teacher_id],
    )
    @timetables = Timetable.with_group.with_teacher_vacancies.where(
      term_id: @term.id,
      'teacher_vacancies.term_teacher_id': params[:term_teacher_id],
    )
    respond_to do |format|
      format.html
      format.pdf do
        pdf = TeacherSchedule.new(@term, [@term_teacher], @tutorial_pieces, @term_groups, @timetables).render
        filename = "#{@room.name}_#{@term.year}年度_#{@term.name}_講師予定表.pdf"
        send_data pdf, filename: filename, type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def bulk_schedule
    @term_teachers = TermTeacher.where(id: params[:term_teacher_id])
    @tutorial_pieces = TutorialPiece.with_tutorial_contract.with_seat_and_timetable.where(
      'term_teachers.id': params[:term_teacher_id],
    )
    @term_groups = Timetable.with_term_group_term_teachers.where(
      term_id: @term.id,
      'term_group_term_teachers.term_teacher_id': params[:term_teacher_id],
    )
    @timetables = Timetable.with_group.with_teacher_vacancies.where(
      term_id: @term.id,
      'teacher_vacancies.term_teacher_id': params[:term_teacher_id],
    )
    respond_to do |format|
      format.pdf do
        pdf = TeacherSchedule.new(@term, @term_teachers, @tutorial_pieces, @term_groups, @timetables).render
        filename = "#{@room.name}_#{@term.year}年度_#{@term.name}_講師予定表.pdf"
        send_data pdf, filename: filename, type: 'application/pdf', disposition: 'inline'
      end
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
