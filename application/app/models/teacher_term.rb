class TeacherTerm < ApplicationRecord
  belongs_to :teacher
  belongs_to :term
  has_many :teacher_requests, dependent: :destroy

  def self.bulk_create(term)
    term.room.exist_teachers.each do |teacher|
      create(term_id: term.id, teacher_id: teacher.id)
    end
  end

  def self.get_teacher_terms(term)
    where(term_id: term.id).reduce({}) do |accu, item|
      accu.merge({ item.teacher_id => item })
    end
  end
end
