class BeginEndTime < ApplicationRecord
  belongs_to :term
  validates :period_index,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :begin_at, presence: true
  validates :end_at, presence: true
end
