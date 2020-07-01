class TeacherTermController < ApplicationController
  before_action :room_signed_in?
  before_action :term_selected?

  def index
    teacher_id = params[:teacher_id]
    @teacher_terms = TeacherTerm.get_teacher_terms(@term)
    if teacher_id.nil?
      render 'teacher_request/index_teacher_list'
    elsif @teacher_terms[teacher_id].not_ready?
      @timetables = Timetable.get_timetables(@term)
      @teacher_requests = TeacherRequest.get_teacher_requests(teacher_id, @term)
      render 'teacher_request/index_status_not_ready'
    elsif @teacher_terms[teacher_id].ready?
      @timetables = Timetable.get_timetables(@term)
      @teacher_requests = TeacherRequest.get_teacher_requests(teacher_id, @term)
      render 'teacher_request/index_status_ready'
    end
  end

  def create
    teacher = Teacher.find_by(id: params[:teacher_id])
    respond_to do |format|
      if TeacherTerm.additional_create(teacher, @term)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
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

  def update_params
    params.require(:teacher_term).permit(:status)
  end
end
