class Subject < ApplicationRecord
  has_many :student_subjects, dependent: :destroy
  has_many :students, through: :student_subjects
  has_many :teacher_subjects, dependent: :destroy
  has_many :teachers, through: :teacher_subjects
  has_many :subject_terms, dependent: :restrict_with_exception
  has_many :terms, through: :subject_terms
  has_many :contracts, dependent: :restrict_with_exception
  has_many :pieces, dependent: :restrict_with_exception
end
