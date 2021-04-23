class Room < ApplicationRecord
  has_many :students, dependent: :restrict_with_exception
  has_many :teachers, dependent: :restrict_with_exception
  has_many :tutorials, dependent: :restrict_with_exception
  has_many :groups, dependent: :restrict_with_exception
  has_many :terms, dependent: :restrict_with_exception

  validates :name,
            length: { minimum: 1, maximum: 20 }

  scope :ordered, -> { order(created_at: 'ASC') }
end
