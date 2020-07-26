class PieceController < ApplicationController
  require './app/pdfs/overlook_schedule'
  require './app/pdfs/student_schedule'
  require './app/pdfs/teacher_schedule'
  before_action :authenticate_room!
  before_action :term_selected?

  def index
    @timetables = Timetable.get_timetables(@term)
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
    gon.teachers = @term.teachers.map do |teacher|
      {
        id: teacher.id,
        name: teacher.name,
      }
    end
    gon.students = @term.students.map do |student|
      {
        id: student.id,
        name: student.name,
      }
    end
    gon.subjects = @term.subjects.map do |subject|
      {
        id: subject.id,
        name: subject.name,
      }
    end
    gon.pendings = @term.pending_pieces
  end
end
