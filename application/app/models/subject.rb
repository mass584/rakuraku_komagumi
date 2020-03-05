class Subject < ApplicationRecord
  has_many :student_subject_mappings, dependent: :destroy
  has_many :students, through: :student_subject_mappings
  has_many :teacher_subject_mappings, dependent: :destroy
  has_many :teachers, through: :teacher_subject_mappings
  has_many :subject_schedulemaster_mappings, dependent: :restrict_with_exception
  has_many :schedulemasters, through: :subject_schedulemaster_mappings
  has_many :classnumbers, dependent: :restrict_with_exception
  has_many :schedules, dependent: :restrict_with_exception
  validates :name,
            presence: true
  validates :order,
            presence: true
  validates :is_deleted,
            presence: true
  validates :room_id,
            presence: true
end
