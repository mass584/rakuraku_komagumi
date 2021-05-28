class TermStudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @term_students_count = @term.term_students.count
    @current_page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = sanitize_integer_query_param(params[:page_size]) || 10
    @term_students = @term.term_students.ordered.pagenated(@current_page, @page_size).named
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
    @student_vacancies = @term_student.student_vacancies.with_timetable
  end

  def schedule
    @term_student = TermStudent.find_by(id: params[:term_student_id])
    respond_to do |format|
      format.html do
        @tutorial_pieces = @term.tutorial_pieces.with_tutorial_contract.with_seat_and_timetable.where(
          'term_students.id': params[:term_student_id],
        )
        @term_groups = @term.timetables.with_group_contracts.where(
          'group_contracts.term_student_id': params[:term_student_id],
          'group_contracts.is_contracted': true,
        )
        @timetables = @term.timetables.with_group.with_student_vacancies.where(
          'student_vacancies.term_student_id': params[:term_student_id],
        )
      end
      format.pdf do
        filename = "#{@room.name}_#{@term.year}年度_#{@term.name}_#{@term_student.student.name}予定表.pdf"
        send_data @term_student.schedule_pdf.render,
                  filename: filename,
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def bulk_schedule
    @term_students = TermStudent.where(id: params[:term_student_id])
    respond_to do |format|
      format.pdf do
        filename = "#{@room.name}_#{@term.year}年度_#{@term.name}_生徒予定表.pdf"
        send_data TermStudent.schedule_pdfs(@term, @term_students).render,
                  filename: filename,
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def bulk_schedule_notification
    @term_students = TermStudent.where(id: params[:term_student_id])
    @term_students.each(&:send_schedule_notification_email)
    @failed = @term_students.filter { |item| item.errors.present? }
    respond_to do |format|
      format.json do
        render json: { error_messages: @failed.map { |item| item.errors.full_messages }.flatten }
      end
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
