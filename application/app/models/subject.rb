class Subject < ApplicationRecord
  belongs_to :room
  has_many :student_subjects, dependent: :destroy
  has_many :students, through: :student_subjects
  has_many :teacher_subjects, dependent: :destroy
  has_many :teachers, through: :teacher_subjects
  has_many :subject_terms, dependent: :restrict_with_exception
  has_many :terms, through: :subject_terms

  validate :verify_maximum, on: :create

  private

  def verify_maximum
    if Subject.where(room_id: room.id, is_deleted: false).count >= 5
      errors[:base] << '登録可能な上限数を超えています。'
    end
  end
end
