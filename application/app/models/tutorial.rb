class Tutorial < ApplicationRecord
  belongs_to :room
  has_many :term_tutorials, dependent: :restrict_with_exception

  validates :name,
            length: { minimum: 1, maximum: 20 }
  validates :order,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  scope :active, -> { where(is_deleted: false) }
  scope :sorted, -> { order(order: 'ASC') }
end
