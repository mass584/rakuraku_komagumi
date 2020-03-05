class ScheduleController < ApplicationController
  before_action :check_login
  before_action :check_schedulemaster
  before_action :check_schedulemaster_batch_status

  def timetables
    return @timetables if defined? @timetables

    @timetables = @schedulemaster.timetables.where(
      date: @schedulemaster.date_array_one_week(week),
    ).order(:date, :period)
    @timetables
  end
  helper_method :timetables

  def schedules
    return @schedules if defined? @schedules

    @schedules = @schedulemaster.schedules.where(
      'timetable_id': timetables.pluck(:id).push(0),
    )
    @schedules
  end
  helper_method :schedules

  def week
    return @week if defined? @week

    @week = params[:week].nil? ? 1 : params[:week].to_i
  end
  helper_method :week

  def index
    get_data_for_front(@schedulemaster)
  end

  def update
    schedule = Schedule.find(params[:id])
    if schedule.update(schedule_params)
      render(json: {}, status: :no_content) && return
    else
      render(json: { message: schedule.errors.full_messages }, status: :bad_request) && return
    end
  end

  def bulk_update
    new_status = params[:status].to_i
    if new_status.zero?
      schedules = @schedulemaster.schedules
    elsif new_status == 1
      schedules = @schedulemaster.schedules.where.not(timetable_id: 0)
    end
    if schedules.update_all(status: new_status)
      render(json: {}, status: :no_content) && return
    else
      render(json: { message: schedules.errors.full_messages }, status: :bad_request) && return
    end
  end

  def bulk_reset
    if @schedulemaster.schedules.update_all(timetable_id: 0, status: 0)
      render(json: {}, status: :no_content) && return
    else
      render(json: { message: schedules.errors.full_messages }, status: :bad_request) && return
    end
  end

  private

  def schedule_params
    params.permit(:teacher_id, :timetable_id, :status)
  end

  def get_data_for_front(@schedulemaster)
    gon.timetables = @schedulemaster.timetables.map { |timetable|
      {
        id: timetable.id,
        scheduledate: timetable.scheduledate,
        classnumber: timetable.classnumber,
        status: timetable.status,
      }
    }
    gon.subjects = @schedulemaster.subjects.map { |subject|
      {
        id: subject.id,
        name: subject.name,
        classtype: subject.classtype,
        row_order: subject.row_order,
      }
    }
    gon.teachers = @schedulemaster.teachers.map { |teacher|
      {
        id: teacher.id,
        fullname: teacher.fullname,
      }
    }
    gon.students = @schedulemaster.students.map { |student|
      {
        id: student.id,
        fullname: student.fullname,
        grade: student.grade_when(@schedulemaster),
      }
    }
    gon.seatnum = @schedulemaster.seatnumber
    gon.teacher_class_max = @schedulemaster.calculation_rules.find_by(eval_target: 'teacher').total_class_max
    gon.teacher_blank_max = @schedulemaster.calculation_rules.find_by(eval_target: 'teacher').blank_class_max
    gon.student_class_max = @schedulemaster.calculation_rules.find_by(eval_target: 'student').total_class_max
    gon.student_blank_max = @schedulemaster.calculation_rules.find_by(eval_target: 'student').blank_class_max
    gon.student3g_class_max = @schedulemaster.calculation_rules.find_by(eval_target: 'student3g').total_class_max
    gon.student3g_blank_max = @schedulemaster.calculation_rules.find_by(eval_target: 'student3g').blank_class_max
  end
end
