class StudentSubjectMapping < ApplicationRecord
  belongs_to :student
  belongs_to :subject
  validates :student_id,
            uniqueness: { scope: :subject_id }
end
