class Contract < ApplicationRecord
  belongs_to :term
  belongs_to :student
  belongs_to :teacher, optional: true
  belongs_to :subject
  validate :can_update_teacher_id, on: :update, if: :teacher_id_changed?
  validate :can_update_number, on: :update, if: :number_changed?
  before_update :before_update_teacher_id, if: :teacher_id_changed?
  before_update :before_update_number, if: :number_changed?

  def self.get_contracts(term)
    term.students.reduce({}) do |ac, st|
      ac.merge(
        st.id.to_s => term.subjects.reduce({}) do |accu, su|
          accu.merge(
            su.id.to_s => find_by(
              term_id: term.id,
              student_id: st.id,
              subject_id: su.id,
            ),
          )
        end,
      )
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
    number = student.subjects.exists?(id: subject.id) ? 1 : 0
    create(
      term_id: term.id,
      student_id: student.id,
      subject_id: subject.id,
      teacher_id: nil,
      number: number,
    )
    return if number.zero?

    Piece.create(
      term_id: term.id,
      student_id: student.id,
      subject_id: subject.id,
      teacher_id: nil,
      timetable_id: nil,
      status: 0,
    )
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

  def can_update_number
    deletable_pieces = term.pieces.where(
      student_id: student_id,
      subject_id: subject_id,
      timetable_id: nil,
    )
    if number_was > number && (number_was - number) > deletable_pieces.count
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

  def before_update_number
    if number > number_was
      (number - number_was).times do
        Piece.create(
          term_id: term_id,
          student_id: student_id,
          teacher_id: teacher_id,
          subject_id: subject_id,
          timetable_id: nil,
          status: 0,
        )
      end
    elsif number < number_was
      (number_was - number).times do
        term.pieces.find_by(
          student_id: student_id,
          subject_id: subject_id,
          timetable_id: nil,
        ).destroy
      end
    end
  end
end
