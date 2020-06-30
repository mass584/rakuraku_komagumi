class StudentTerm < ApplicationRecord
  belongs_to :student
  belongs_to :term
  enum status: { not_ready: 0, ready: 1 }

  def self.bulk_create(term)
    term.room.exist_students.each do |student|
      create(
        term_id: term.id,
        student_id: student.id,
      )
    end
  end

  def self.additional_create(student, term)
    new(
      term_id: term.id,
      student_id: student.id,
      status: 0,
    ).save && Contract.bulk_create_for_student(
      student,
      term,
    )
  end

  def self.get_student_terms(term)
    where(term_id: term.id).reduce({}) do |accu, item|
      accu.merge({ item.id => item })
    end
  end
end
