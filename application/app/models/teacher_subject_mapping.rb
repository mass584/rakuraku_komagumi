class TeacherSubjectMapping < ApplicationRecord
  belongs_to :teacher
  belongs_to :subject
  validates :teacher_id,
            presence: true,
            uniqueness: { scope: :subject_id }
  validates :subject_id,
            presence: true
end
