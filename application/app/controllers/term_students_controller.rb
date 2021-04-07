class TermStudentsController < ApplicationController
  PAGE_SIZE = 7

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = PAGE_SIZE
    @term_students = current_term.term_students.ordered.pagenated(@page, @page_size)
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

  def show
    @student_term = StudentTerm.find(params[:id])
    @timetables = Timetable.get_timetables(@term)
    @student_requests = StudentRequest.get_student_requests(@student_term, @term)
    @week = @term.week(params[:week].to_i)
  end

  def schedule
    @student_term = StudentTerm.find(params[:id])
    @timetables = Timetable.get_timetables(@term)
    @student_requests = StudentRequest.get_student_requests(@student_term, @term)
    @week = @term.week(params[:week].to_i)
    @pieces = Piece.get_pieces_for_student(@term, @student_term)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = StudentSchedule.new(
          @term, @student_term, @pieces, @student_requests
        ).render
        send_data pdf,
                  filename: "#{@term.name}予定表#{@student_term.student.name}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def update
    record = StudentTerm.find(params[:id])
    if record.update(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:term_student).permit(:term_id, :student_id, :school_grade)
  end

  def update_params
    params.require(:student_term).permit(:is_decided)
  end
end
