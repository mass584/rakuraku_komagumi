class TeacherTerm < ApplicationRecord
  belongs_to :teacher
  belongs_to :term
  enum status: { not_ready: 0, ready: 1 }

  def self.bulk_create(term)
    term.room.exist_teachers.each do |teacher|
      create(
        term_id: term.id,
        teacher_id: teacher.id,
        status: 0,
      )
    end
  end

  def self.get_teacher_terms(term)
    where(term_id: term.id).reduce({}) do |accu, item|
      accu.merge({ item.teacher_id => item })
    end
  end
end
