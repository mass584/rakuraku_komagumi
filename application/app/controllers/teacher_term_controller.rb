class TeacherTermController < ApplicationController
  before_action :authenticate_room!
  before_action :term_selected?

  def index
    @teacher_terms = TeacherTerm.get_teacher_terms(@term)
    @page = params[:page].to_i || 1
  end

  def show
    @teacher_term = TeacherTerm.find(params[:id])
    @timetables = Timetable.get_timetables(@term)
    @teacher_requests = TeacherRequest.get_teacher_requests(@teacher_term, @term)
    @week = @term.week(params[:week].to_i)
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
