class TeacherTerm < ApplicationRecord
  belongs_to :teacher
  belongs_to :term

  def self.bulk_create(term)
    term.room.exist_teachers.each do |teacher|
      create(
        term_id: term.id,
        teacher_id: teacher.id,
      )
    end
  end

  def self.additional_create(teacher, term)
    TeacherTerm.new(
      term_id: term.id,
      teacher_id: teacher.id,
    ).save && TeacherTerm.new(
      teacher_id: teacher.id,
      term_id: term.id,
      status: 0,
    ).save
  end
end
