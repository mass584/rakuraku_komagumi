class OptimizationLog < ApplicationRecord
  belongs_to :term

  validates :installation_progress,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :swapping_progress,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :deletion_progress,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :exit_status, presence: true

  before_create :set_is_optimizing
  before_update :unset_is_optimizing, if: :will_save_change_to_exit_status?

  enum exit_status: {
    in_progress: 0,
    succeed: 1,
    failed: 2,
  }

  def self.new(attr = {})
    attr[:installation_progress] ||= 0
    attr[:swapping_progress] ||= 0
    attr[:deletion_progress] ||= 0
    attr[:exit_status] ||= 0
    super(attr)
  end

  private

  def set_is_optimizing
    self.sequence_number = next_sequence_number
    term.is_optimizing = true
  end

  def unset_is_optimizing
    self.end_at = Time.zone.now
    term.is_optimizing = false
  end

  def next_sequence_number
    maximum_sequence_number = self.class.where(term_id: term_id).maximum(:sequence_number)
    maximum_sequence_number.present? ? maximum_sequence_number + 1 : 1
  end
end
