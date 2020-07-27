class PieceController < ApplicationController
  require './app/pdfs/overlook_schedule'
  require './app/pdfs/student_schedule'
  require './app/pdfs/teacher_schedule'
  before_action :authenticate_room!
  before_action :term_selected?

  def index
    @seats = Seat.get_seats(@term)
    @week = @term.week(params[:week].to_i)
    respond_to do |format|
      format.html do
        case params[:show_type]
        when 'per_teacher'
          render 'piece/index_per_teacher'
        when 'per_student'
          render 'piece/index_per_student'
        else
          use_gon
          render 'piece/index'
        end
      end
    end
  end

  def update
    record = Piece.find(params[:id])
    if record.update(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  def bulk_update
    records = @term.pieces.where.not(seat_id: nil)
    if records.update_all(bulk_update_params)
      render json: {}, status: :no_content
    else
      render json: { message: records.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:piece).permit(:seat_id, :is_fixed)
  end

  def bulk_update_params
    params.require(:piece).permit(:is_fixed)
  end

  def use_gon
    gon.teacher_terms = @term.teacher_terms.joins(:teacher).map do |teacher_term|
      {
        id: teacher_term.id,
        name: teacher_term.teacher.name,
      }
    end
    gon.student_terms = @term.student_terms.joins(:student).map do |student_term|
      {
        id: student_term.id,
        name: student_term.student.name,
        grade: student_term.student.grade_at(@term.year),
      }
    end
    gon.subject_terms = @term.subject_terms.joins(:subject).map do |subject_term|
      {
        id: subject_term.id,
        name: subject_term.subject.name,
      }
    end
    gon.pendings = @term.pendings
  end
end
