class StudentSubjectMapping < ApplicationRecord
  belongs_to :student
  belongs_to :subject
  validates :student_id,
            presence: true,
            uniqueness: { scope: :subject_id }
  validates :subject_id,
            presence: true
end
