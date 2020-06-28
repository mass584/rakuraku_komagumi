class Room < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :trackable
  has_many :schedulemasters, dependent: :restrict_with_exception
  has_many :teachers, dependent: :restrict_with_exception
  has_many :students, dependent: :restrict_with_exception
  has_many :subjects, dependent: :restrict_with_exception
  validates :password,
            length: { maximum: 16, minimum: 8 },
            format: { with: /\A[a-zA-Z0-9]{8,16}+\z/i }

  def exist_students
    students.where(is_deleted: false).order(birth_year: 'ASC', name: 'ASC')
  end

  def exist_teachers
    teachers.where(is_deleted: false).order(name: 'ASC')
  end

  def exist_subjects
    subjects.where(is_deleted: false).order(order: 'ASC')
  end
end
