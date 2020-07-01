class StudentTermController < ApplicationController
  before_action :room_signed_in?
  before_action :term_selected?

  def index
    student_id = params[:student_id]
    @student_terms = StudentTerm.get_student_terms(@term)
    if student_id.nil?
      render 'student_request/index_student_list'
    elsif @student_terms[student_id].not_ready?
      @timetables = Timetable.get_timetables(@term)
      @student_requests = StudentRequest.get_student_requests(student_id, @term)
      render 'student_request/index_status_not_ready'
    elsif @student_terms[student_id].ready?
      @timetables = Timetable.get_timetables(@term)
      @student_requests = StudentRequest.get_student_requests(student_id, @term)
      render 'student_request/index_status_ready'
    end
  end

  def create
    student = Student.find_by(id: params[:student_id])
    respond_to do |format|
      if StudentTerm.additional_create(student, @term)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
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

  def update_params
    params.require(:student_term).permit(:status)
  end
end
