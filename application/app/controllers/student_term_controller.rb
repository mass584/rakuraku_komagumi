class StudentTermController < ApplicationController
  before_action :authenticate_room!
  before_action :term_selected?

  def index
    @student_terms = StudentTerm.get_student_terms(@term)
    @page = params[:page].to_i || 1
  end

  def show
    @student_term = StudentTerm.find(params[:id])
    @timetables = Timetable.get_timetables(@term)
    @student_requests = StudentRequest.get_student_requests(@student_term, @term)
    @week = @term.week(params[:week].to_i)
  end

  def create
    @student_term = StudentTerm.new(create_params)
    respond_to do |format|
      if @student_term.save
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
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
    params.require(:student_term).permit(:student_id).merge({ term_id: @term.id })
  end

  def update_params
    params.require(:student_term).permit(:is_decided)
  end
end
