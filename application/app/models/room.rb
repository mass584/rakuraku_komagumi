class Room < ApplicationRecord
  has_many :schedulemasters, dependent: :restrict_with_exception
  has_many :teachers, dependent: :restrict_with_exception
  has_many :students, dependent: :restrict_with_exception
  has_many :subjects, dependent: :restrict_with_exception
  has_secure_password
  validates :name,
            presence: true
  validates :email,
            format: { with: /\A([^@\s]+)@(([-a-z0-9]+\.)+[a-z]{2,})\z/ },
            uniqueness: true,
            presence: true
  validates :password,
            presence: true,
            allow_blank: true,
            length: { maximum: 16, minimum: 8 },
            format: { with: /\A[a-zA-Z0-9]{8,16}+\z/i }

def exist_students
    grade_index = %w[小6 中1 中2 中3]
    students.where(is_deleted: false).sort do |a, b|
      a.firstname_kana <=> b.firstname_kana
    end.sort do |a, b|
      a.lastname_kana <=> b.lastname_kana
    end.sort do |a, b|
      grade_index.find_index(a.grade) <=> grade_index.find_index(b.grade)
    end
  end

  def exist_teachers
    teachers.where(is_deleted: false)
  end

  def exist_subjects
    subjects.where(is_deleted: false).order(:row_order)
  end
end
