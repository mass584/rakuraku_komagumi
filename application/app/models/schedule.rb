class Schedule < ApplicationRecord
  belongs_to :schedulemaster
  belongs_to :student
  belongs_to :teacher, optional: true
  belongs_to :subject
  belongs_to :timetable, optional: true
  validates :schedulemaster_id,
            presence: true
  validates :student_id,
            presence: true
  validates :subject_id,
            presence: true
  validates :status,
            presence: true
  validate :verify_teacher_occupation_on_create, on: :create
  validate :verify_student_occupation_on_create, on: :create
  validate :verify_teacher_occupation_on_update, on: :update
  validate :verify_student_occupation_on_update, on: :update

  def self.get_student_schedules(student_id, schedulemaster)
    schedules = Hash.new { |h, k| h[k] = {} }
    schedulemaster.timetables.order(:date, :period).each do |timetable|
      schedules[timetable.date][timetable.period] =
        joins(:subject, :teacher).where(
          schedulemaster_id: schedulemaster.id,
          timetable_id: timetable.id,
          student_id: student_id,
        )
    end
    schedules
  end

  def self.get_teacher_schedules(teacher_id, schedulemaster)
    schedules = Hash.new { |h, k| h[k] = {} }
    schedulemaster.timetables.order(:date, :period).each do |timetable|
      schedules[timetable.date][timetable.period] =
        joins(:subject, :student).where(
          schedulemaster_id: schedulemaster.id,
          timetable_id: timetable.id,
          teacher_id: teacher_id,
        )
    end
    schedules
  end

  def self.get_all_schedules(schedulemaster)
    schedules = Hash.new { |h, k| h[k] = {} }
    schedulemaster.timetables.order(:date, :period).each do |timetable|
      schedules[timetable.date][timetable.period] = []
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

  private

  def verify_teacher_occupation_on_create
    return if teacher_id.nil? || timetable_id.nil?

    teacher_occupation_count = self.class.where(
      schedulemaster_id: schedulemaster_id,
      teacher_id: teacher_id,
      timetable_id: timetable_id,
    ).count
    if teacher_occupation_count >= schedulemaster.class_per_teacher
      errors[:base] << '講師のオーバーブッキングがあります'
    end
  end

  def verify_student_occupation_on_create
    return if timetable_id.nil?

    student_occupation_count = self.class.where(
      schedulemaster_id: schedulemaster_id,
      student_id: student_id,
      timetable_id: timetable_id,
    ).count
    if student_occupation_count >= 1
      errors[:base] << '生徒のダブルブッキングがあります'
    end
  end

  def verify_teacher_occupation_on_update
    return if teacher_id.nil? || timetable_id.nil?

    schedule_changed = timetable_id.changed? || teacher_id.changed?
    teacher_occupation_count = self.class.where(
      schedulemaster_id: schedulemaster_id,
      teacher_id: teacher_id,
      timetable_id: timetable_id,
    ).count
    if schedule_changed && (teacher_occupation_count >= schedulemaster.class_per_teacher)
      errors[:base] << '講師のオーバーブッキングがあります'
    end
  end

  def verify_student_occupation_on_update
    return if timetable_id.zero?

    schedule_changed = timetable_id.changed?
    student_occupation_count = self.class.where(
      schedulemaster_id: schedulemaster_id,
      student_id: student_id,
      timetable_id: timetable_id,
    ).count
    if schedule_changed && (student_occupation_count >= 1)
      errors[:base] << '生徒のダブルブッキングがあります'
    end
  end
end
