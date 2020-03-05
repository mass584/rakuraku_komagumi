class Schedule < ApplicationRecord
  belongs_to :schedulemaster
  belongs_to :student
  belongs_to :teacher, optional: true
  belongs_to :subject
  belongs_to :timetable, optional: true
  validate :check_teacher_occupation_on_create, on: :create
  validate :check_student_occupation_on_create, on: :create
  validate :check_teacher_occupation_on_update, on: :update
  validate :check_student_occupation_on_update, on: :update
  TEACHER_OCCUPATION_ERROR_MSG = '一人の講師に対し３コマ以上の授業を割り当てることはできません'.freeze
  STUDENT_OCCUPATION_ERROR_MSG = '一人の生徒に対し２コマ以上の授業を割り当てることはできません'.freeze

  def self.get_student_schedules(student_id, schedulemaster)
    schedules = Hash.new { |h, k| h[k] = {} }
    schedulemaster.timetables.order(:scheduledate, :classnumber).each do |ti|
      schedules[ti.scheduledate][ti.classnumber] =
        joins(:subject, :teacher).where(
          schedulemaster_id: schedulemaster.id,
          timetable_id: ti.id,
          student_id: student_id,
        )
    end
    schedules
  end

  def self.get_teacher_schedules(teacher_id, schedulemaster)
    schedules = Hash.new { |h, k| h[k] = {} }
    schedulemaster.timetables.order(:scheduledate, :classnumber).each do |ti|
      schedules[ti.scheduledate][ti.classnumber] =
        joins(:subject, :student).where(
          schedulemaster_id: schedulemaster.id,
          timetable_id: ti.id,
          teacher_id: teacher_id,
        )
    end
    schedules
  end

  def self.get_all_schedules(schedulemaster)
    schedules = Hash.new { |h, k| h[k] = {} }
    schedulemaster.timetables.order(:scheduledate, :classnumber).each do |timetable|
      schedules[timetable.scheduledate][timetable.classnumber] = []
      schedulemaster.teachers.each do |teacher|
        komas_per_seat =
          schedulemaster.schedules.joins(:subject, :student, :teacher).where(timetable_id: timetable.id, teacher_id: teacher.id)
        if komas_per_seat.present?
          schedules[timetable.scheduledate][timetable.classnumber].push(komas_per_seat)
        end
      end
    end
    schedules
  end

  def check_teacher_occupation_on_create
    return if teacher_id.zero? || timetable_id.zero?

    teacher_occupation_count = self.class.where(
      schedulemaster_id: schedulemaster_id,
      teacher_id: teacher_id,
      timetable_id: timetable_id,
    ).count
    if teacher_occupation_count >= 2
      errors.add(:timetable_id, TEACHER_OCCUPATION_ERROR_MSG)
    end
  end

  def check_student_occupation_on_create
    return if timetable_id.zero?

    student_occupation_count = self.class.where(
      schedulemaster_id: schedulemaster_id,
      student_id: student_id,
      timetable_id: timetable_id,
    ).count
    if student_occupation_count >= 1
      errors.add(:timetable_id, STUDENT_OCCUPATION_ERROR_MSG)
    end
  end

  def check_teacher_occupation_on_update
    return if teacher_id.zero? || timetable_id.zero?

    schedule_before = self.class.find(id)
    schedule_changed = (schedule_before.timetable_id != timetable_id) || (schedule_before.teacher_id != teacher_id)
    teacher_occupation_count = self.class.where(
      schedulemaster_id: schedulemaster_id,
      teacher_id: teacher_id,
      timetable_id: timetable_id,
    ).count
    if schedule_changed && (teacher_occupation_count >= 2)
      errors.add(:timetable_id, TEACHER_OCCUPATION_ERROR_MSG)
    end
  end

  def check_student_occupation_on_update
    return if timetable_id.zero?

    schedule_before = self.class.find(id)
    schedule_changed = (schedule_before.timetable_id != timetable_id)
    student_occupation_count = self.class.where(
      schedulemaster_id: schedulemaster_id,
      student_id: student_id,
      timetable_id: timetable_id,
    ).count
    if schedule_changed && (student_occupation_count >= 1)
      errors.add(:timetable_id, STUDENT_OCCUPATION_ERROR_MSG)
    end
  end
end
