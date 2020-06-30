class StudentTerm < ApplicationRecord
  belongs_to :student
  belongs_to :term

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
    ).save && StudentTerm.new(
      term_id: term.id,
      student_id: student.id,
      status: 0,
    ).save && Contract.bulk_create_for_student(
      student,
      term,
    )
  end
end
