class PieceController < ApplicationController
  require './app/pdfs/overlook_schedule'
  require './app/pdfs/student_schedule'
  require './app/pdfs/teacher_schedule'
  before_action :room_signed_in?
  before_action :term_selected?

  def index
    @timetables = Timetable.get_timetables(@term)
    respond_to do |format|
      format.html do
        case params[:show_type]
        when 'per_teacher'
          render 'show_per_teacher'
        when 'per_student'
          render 'show_per_student'
        else
          use_gon
        end
      end
      format.pdf do
        case params[:show_type]
        when 'per_teacher'
          teacher_ids = params[:teacher_ids].gsub(/[\"|\[|\]]/, '').split(',')
          pdf = TeacherSchedule.new(@term.id, teacher_ids).render
          send_data pdf,
                    filename: "講師予定表_#{@term.id}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline'
        when 'per_student'
          student_ids = params[:student_ids].gsub(/[\"|\[|\]]/, '').split(',')
          pdf = StudentSchedule.new(@term.id, student_ids).render
          send_data pdf,
                    filename: "生徒予定表_#{@term.id}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline'
        else
          pdf = OverlookSchedule.new(@term.id).render
          send_data pdf,
                    filename: "全体予定表_#{@term.id}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline'
        end
      end
    end
  end

  def update
    record = Piece.find(params[:id])
    if record.update(update_params)
      render json: {}, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  def bulk_update
    records = @term.pieces.where.not(timetable_id: nil)
    if records.update_all(bulk_update_params)
      render json: {}, status: :ok
    else
      render json: { message: records.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:piece).permit(
      :teacher_id,
      :timetable_id,
      :status,
    )
  end

  def bulk_update_params
    params.require(:piece).permit(
      :status,
    )
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
