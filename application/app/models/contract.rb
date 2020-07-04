class Contract < ApplicationRecord
  belongs_to :term
  belongs_to :student
  belongs_to :teacher, optional: true
  belongs_to :subject
  validate :can_update_teacher_id, on: :update, if: :teacher_id_changed?
  validate :can_update_count, on: :update, if: :count_changed?
  before_update :before_update_teacher_id, if: :teacher_id_changed?
  before_update :before_update_count, if: :count_changed?

  def self.get_contracts(term_id)
    where(term_id: term_id).reduce({}) do |accu, item|
      accu.deep_merge({
        item.student_id => {
          item.subject_id => item,
        },
      })
    end
  end

  def self.bulk_create(term)
    term.students.each do |student|
      term.subjects.each do |subject|
        create_with_piece(student, subject, term)
      end
    end
  end

  def self.bulk_create_for_student(student, term)
    term.subjects.each do |subject|
      create_with_piece(student, subject, term)
    end
  end

  def self.bulk_create_for_subject(subject, term)
    term.students.each do |student|
      create_with_piece(student, subject, term)
    end
  end

  def self.create_with_piece(student, subject, term)
    is_subscribed = student.subjects.exists?(id: subject.id)
    if is_subscribed
      create(
        term_id: term.id,
        student_id: student.id,
        subject_id: subject.id,
        teacher_id: nil,
        count: 1,
      )
      Piece.create(
        term_id: term.id,
        student_id: student.id,
        subject_id: subject.id,
        teacher_id: nil,
        timetable_id: nil,
        status: 0,
      )
    else
      create(
        term_id: term.id,
        student_id: student.id,
        subject_id: subject.id,
        teacher_id: nil,
        count: 0,
      )
    end
  end

  private

  def can_update_teacher_id
    assigned_pieces = term.pieces.where(
      student_id: student_id,
      subject_id: subject_id,
    ).where.not(
      timetable_id: nil,
    )
    if assigned_pieces.count.positive?
      errors[:base] << '予定が決定済の授業があるため、担任の先生を変更することが出来ません。
        変更したい場合は、この画面で該当する授業を削除し、再設定を行ってください。'
    end
  end

  def can_update_count
    deletable_pieces = term.pieces.where(
      student_id: student_id,
      subject_id: subject_id,
      timetable_id: nil,
    )
    if count_was > count && (count_was - count) > deletable_pieces.count
      errors[:base] << '授業回数を、予定決定済の授業数よりも少なくすることは出来ません。
        少なくしたい場合は、全体予定編集画面で決定済の授業を未決定に戻してください。'
    end
  end

  def before_update_teacher_id
    term.pieces.where(
      student_id: student_id,
      subject_id: subject_id,
    ).update_all(
      teacher_id: teacher_id,
    )
  end

  def before_update_count
    if count > count_was
      (count - count_was).times do
        Piece.create(
          term_id: term_id,
          student_id: student_id,
          teacher_id: teacher_id,
          subject_id: subject_id,
          timetable_id: nil,
          status: 0,
        )
      end
    elsif count < count_was
      (count_was - count).times do
        term.pieces.find_by(
          student_id: student_id,
          subject_id: subject_id,
          timetable_id: nil,
        ).destroy
      end
    end
  end
end
