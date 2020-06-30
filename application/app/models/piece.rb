class Piece < ApplicationRecord
  belongs_to :term
  belongs_to :student
  belongs_to :teacher, optional: true
  belongs_to :subject
  belongs_to :timetable, optional: true
  validate :verify_teacher_occupation_on_create, on: :create
  validate :verify_student_occupation_on_create, on: :create
  validate :verify_teacher_occupation_on_update, on: :update
  validate :verify_student_occupation_on_update, on: :update

  def self.get_student_pieces(student_id, term)
    schedules = Hash.new { |h, k| h[k] = {} }
    term.timetables.order(:date, :period).each do |timetable|
      schedules[timetable.date][timetable.period] =
        joins(:subject, :teacher).where(
          term_id: term.id,
          timetable_id: timetable.id,
          student_id: student_id,
        )
    end
    schedules
  end

  def self.get_teacher_pieces(teacher_id, term)
    schedules = Hash.new { |h, k| h[k] = {} }
    term.timetables.order(:date, :period).each do |timetable|
      schedules[timetable.date][timetable.period] =
        joins(:subject, :student).where(
          term_id: term.id,
          timetable_id: timetable.id,
          teacher_id: teacher_id,
        )
    end
    schedules
  end

  def self.get_all_pieces(term)
    schedules = Hash.new { |h, k| h[k] = {} }
    term.timetables.order(:date, :period).each do |timetable|
      schedules[timetable.date][timetable.period] = []
      term.teachers.each do |teacher|
        pieces_per_seat =
          term.pieces.joins(:subject, :student, :teacher).where(timetable_id: timetable.id, teacher_id: teacher.id)
        if komas_per_seat.present?
          schedules[timetable.date][timetable.period].push(pieces_per_seat)
        end
      end
    end
    schedules
  end

  private

  def verify_teacher_occupation_on_create
    return if teacher_id.nil? || timetable_id.nil?

    teacher_occupation_count = self.class.where(
      term_id: term_id,
      teacher_id: teacher_id,
      timetable_id: timetable_id,
    ).count
    if teacher_occupation_count >= term.class_per_teacher
      errors[:base] << '講師のオーバーブッキングがあります'
    end
  end

  def verify_student_occupation_on_create
    return if timetable_id.nil?

    student_occupation_count = self.class.where(
      term_id: term_id,
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
      term_id: term_id,
      teacher_id: teacher_id,
      timetable_id: timetable_id,
    ).count
    if schedule_changed && (teacher_occupation_count >= term.class_per_teacher)
      errors[:base] << '講師のオーバーブッキングがあります'
    end
  end

  def verify_student_occupation_on_update
    return if timetable_id.zero?

    schedule_changed = timetable_id.changed?
    student_occupation_count = self.class.where(
      term_id: term_id,
      student_id: student_id,
      timetable_id: timetable_id,
    ).count
    if schedule_changed && (student_occupation_count >= 1)
      errors[:base] << '生徒のダブルブッキングがあります'
    end
  end
end
