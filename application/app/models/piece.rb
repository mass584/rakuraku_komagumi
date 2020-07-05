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
  enum status: { unfixed: 0, fixed: 1 }

  private

  def verify_teacher_occupation_on_create
    return if teacher_id.nil? || timetable_id.nil?

    teacher_occupation_count = where(
      term_id: term.id,
      teacher_id: teacher_id,
      timetable_id: timetable_id,
    ).count
    if teacher_occupation_count >= term.max_piece
      errors[:base] << '講師のオーバーブッキングがあります'
    end
  end

  def verify_student_occupation_on_create
    return if timetable_id.nil?

    student_occupation_count = where(
      term_id: term.id,
      student_id: student_id,
      timetable_id: timetable_id,
    ).count
    if student_occupation_count >= 1
      errors[:base] << '生徒のダブルブッキングがあります'
    end
  end

  def verify_teacher_occupation_on_update
    return if teacher_id.nil? || timetable_id.nil?

    schedule_changed = timetable_id_changed? || teacher_id_changed?
    teacher_occupation_count = Piece.where(
      term_id: term.id,
      teacher_id: teacher_id,
      timetable_id: timetable_id,
    ).count
    if schedule_changed && (teacher_occupation_count >= term.max_piece)
      errors[:base] << '講師のオーバーブッキングがあります'
    end
  end

  def verify_student_occupation_on_update
    return if timetable_id.nil?

    schedule_changed = timetable_id_changed?
    student_occupation_count = Piece.where(
      term_id: term.id,
      student_id: student_id,
      timetable_id: timetable_id,
    ).count
    if schedule_changed && (student_occupation_count >= 1)
      errors[:base] << '生徒のダブルブッキングがあります'
    end
  end
end
