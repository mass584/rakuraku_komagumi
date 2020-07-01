class PieceController < ApplicationController
  require './app/pdfs/overlook_schedule'
  require './app/pdfs/student_schedule'
  require './app/pdfs/teacher_schedule'
  before_action :room_signed_in?
  before_action :term_selected?

  def timetables
    return @timetables if defined? @timetables

    @timetables = @term.timetables.where(
      date: @term.date_array_one_week(week),
    ).order(:date, :period)
    @timetables
  end
  helper_method :timetables

  def pieces
    return @pieces if defined? @pieces

    @pieces = @term.schedules.where(
      'timetable_id': timetables.pluck(:id).push(0),
    )
    @pieces
  end
  helper_method :pieces

  def week
    return @week if defined? @week

    @week = params[:week].nil? ? 1 : params[:week].to_i
  end
  helper_method :week

  def index
    respond_to do |format|
      format.html do
        case params[:show_type]
        when 'per_teacher'
          render 'show_per_teacher'
        when 'per_student'
          render 'show_per_student'
        else
          gon(@term)
          render 'show_overlook'
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

  def gon(term)
    gon.timetables = term.timetables.map do |timetable|
      {
        id: timetable.id,
        scheduledate: timetable.scheduledate,
        classnumber: timetable.classnumber,
        status: timetable.status,
      }
    end
    gon.subjects = term.subjects.map do |subject|
      {
        id: subject.id,
        name: subject.name,
        classtype: subject.classtype,
        row_order: subject.row_order,
      }
    end
    gon.teachers = term.teachers.map do |teacher|
      {
        id: teacher.id,
        fullname: teacher.fullname,
      }
    end
    gon.students = term.students.map do |student|
      {
        id: student.id,
        fullname: student.fullname,
        grade: student.grade_when(term),
      }
    end
  end
end
