class StudentTerm < ApplicationRecord
  belongs_to :student
  belongs_to :term
  has_many :student_requests, dependent: :destroy

  after_create :create_contract

  def self.bulk_create(term)
    term.room.exist_students.each do |student|
      create(term_id: term.id, student_id: student.id)
    end
  end

  def self.get_student_terms(term)
    where(term_id: term.id).reduce({}) do |accu, item|
      accu.merge({ item.student_id => item })
    end
  end

  def create_contract
    Contract.bulk_create_for_student(self, term)
  end
end
