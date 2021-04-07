class BeginEndTime < ApplicationRecord
  belongs_to :term
  validates :period_index,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :begin_at, presence: true
  validates :end_at, presence: true

  def self.begin_end_times_group_by_period(term)
    term.begin_end_times.select(:id, :period_index, :begin_at, :end_at).group_by_recursive(
      proc { |item| item[:period_index] },
    )
  end
end
