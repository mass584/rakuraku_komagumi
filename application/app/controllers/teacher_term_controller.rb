class TeacherTermController < ApplicationController
  before_action :authenticate_user!
  before_action :term_selected?

  def index
    respond_to do |format|
      format.html do
        @teacher_terms = TeacherTerm.get_teacher_terms(@term)
        @page = params[:page].to_i || 1
      end
      format.json do
        render json: TeacherTerm.where(term_id: @term.id).to_json, status: :ok
      end
    end
  end

  def show
    @teacher_term = TeacherTerm.find(params[:id])
    @timetables = Timetable.get_timetables(@term)
    @teacher_requests = TeacherRequest.get_teacher_requests(@teacher_term, @term)
    @week = @term.week(params[:week].to_i)
  end

  def schedule
    @teacher_term = TeacherTerm.find(params[:id])
    @timetables = Timetable.get_timetables(@term)
    @teacher_requests = TeacherRequest.get_teacher_requests(@teacher_term, @term)
    @week = @term.week(params[:week].to_i)
    @pieces = Piece.get_pieces_for_teacher(@term, @teacher_term)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = TeacherSchedule.new(
          @term, @teacher_term, @pieces, @teacher_requests
        ).render
        send_data pdf,
                  filename: "#{@term.name}予定表#{@teacher_term.teacher.name}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def create
    @teacher_term = TeacherTerm.new(create_params)
    respond_to do |format|
      if @teacher_term.save
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def update
    record = TeacherTerm.find(params[:id])
    if record.update(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:teacher_term).permit(:teacher_id).merge({ term_id: @term.id })
  end

  def update_params
    params.require(:teacher_term).permit(:is_decided)
  end
end
