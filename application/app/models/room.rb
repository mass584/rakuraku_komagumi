class Room < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :trackable,
         password_length: 8..128
  has_many :terms, dependent: :restrict_with_exception
  has_many :teachers, dependent: :restrict_with_exception
  has_many :students, dependent: :restrict_with_exception
  has_many :subjects, dependent: :restrict_with_exception
  validates :name, presence: true

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
