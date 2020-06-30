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

  def self.get_pieces_for_student(student_id, term_id)
    to_hash(
      pieces.where(
        term_id: term_id,
        student_id: student_id,
      ).where.not(
        timetable_id: nil,
      )
    )
  end

  def self.get_pieces_for_teacher(teacher_id, term_id)
    to_hash(
      pieces.where(
        term_id: term_id,
        teacher_id: teacher_id,
      ).where.not(
        timetable_id: nil,
      ),
    )
  end

  def self.get_all_pieces(term_id)
    to_hash(
      pieces.where(
        term_id: term_id,
      ).where.not(
        timetable_id: nil,
      ),
    )
  end

  private

  def to_hash(items)
    items.reduce({}) do |accu, item|
      arr = accu.dig(item.timetable.date, item.timetable.period).to_a
      accu.deep_merge({
        item.timetable.date => {
          item.timetable.period => arr + [item],
        },
      })
    end
  end

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

    schedule_changed = timetable_id.changed? || teacher_id.changed?
    teacher_occupation_count = where(
      term_id: term.id,
      teacher_id: teacher_id,
      timetable_id: timetable_id,
    ).count
    if schedule_changed && (teacher_occupation_count >= term.max_piece)
      errors[:base] << '講師のオーバーブッキングがあります'
    end
  end

  def verify_student_occupation_on_update
    return if timetable_id.zero?

    schedule_changed = timetable_id.changed?
    student_occupation_count = where(
      term_id: term.id,
      student_id: student_id,
      timetable_id: timetable_id,
    ).count
    if schedule_changed && (student_occupation_count >= 1)
      errors[:base] << '生徒のダブルブッキングがあります'
    end
  end
end
