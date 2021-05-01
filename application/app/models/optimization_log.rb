class OptimizationLog < ApplicationRecord
  belongs_to :term

  validates :sequence_number,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :installation_progress,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :swapping_progress,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :deletion_progress,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :exit_status, presence: true

  enum exit_status: {
    in_progress: 0,
    succeed: 1,
    failed: 2,
  }
end
