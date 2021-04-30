class StudentOptimizationRule < ApplicationRecord
  belongs_to :term

  validates :occupation_limit,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 12,
            }
  validates :occupation_costs,
            presence: true
  validates :serialized_occupation_costs,
            format: { with: /\A[0-9\s]*\Z/, message: 'は整数で入力してください' },
            allow_nil: true
  validates :blank_limit,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 10,
            }
  validates :blank_costs,
            presence: true
  validates :serialized_blank_costs,
            format: { with: /\A[0-9\s]*\Z/, message: 'は整数で入力してください' },
            allow_nil: true
  validates :interval_cutoff,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 7,
            }
  validates :interval_costs,
            presence: true
  validates :serialized_interval_costs,
            format: { with: /\A[0-9\s]*\Z/, message: 'は整数で入力してください' },
            allow_nil: true

  enum school_grade: {
    e1: 11,
    e2: 12,
    e3: 13,
    e4: 14,
    e5: 15,
    e6: 16,
    j1: 21,
    j2: 22,
    j3: 23,
    h1: 31,
    h2: 32,
    h3: 33,
    other: 99,
  }

  validate :tutorial_piece_empty?
  validate :occupation_costs_valid?
  validate :blank_costs_valid?
  validate :interval_costs_valid?

  before_validation :deserialize_occupation_costs
  before_validation :deserialize_blank_costs
  before_validation :deserialize_interval_costs
  after_find :serialize_occupation_costs
  after_find :serialize_blank_costs
  after_find :serialize_interval_costs

  scope :ordered, -> { order(school_grade: 'ASC') }

  attr_accessor :serialized_occupation_costs,
                :serialized_blank_costs,
                :serialized_interval_costs

  def editable
    !term.tutorial_pieces.filter_by_placed.exists?
  end

  private

  def tutorial_piece_empty?
    unless editable
      errors.add(:base, 'コマが配置されているため変更できません')
    end
  end

  def occupation_costs_valid?
    unless occupation_costs.length == occupation_limit + 1
      errors.add(:occupation_costs, 'の設定数が間違えています')
    end

    if occupation_costs.any? { |value| value.negative? || value > 100 }
      errors.add(:occupation_costs, 'は０〜１００を指定してください')
    end
  end

  def blank_costs_valid?
    unless blank_costs.length == blank_limit + 1
      errors.add(:blank_costs, 'の設定数が間違えています')
    end

    if blank_costs.any? { |value| value.negative? || value > 100 }
      errors.add(:blank_costs, 'は０〜１００を指定してください')
    end
  end

  def interval_costs_valid?
    unless interval_costs.length == interval_cutoff + 1
      errors.add(:interval_costs, 'の設定数が間違えています')
    end

    if interval_costs.any? { |value| value.negative? || value > 100 }
      errors.add(:interval_costs, 'は０〜１００を指定してください')
    end
  end

  def deserialize_occupation_costs
    if serialized_occupation_costs.present?
      self.occupation_costs = [0] + serialized_occupation_costs.split
    end
  end

  def deserialize_blank_costs
    if serialized_blank_costs.present?
      self.blank_costs = [0] + serialized_blank_costs.split
    end
  end

  def deserialize_interval_costs
    if serialized_interval_costs.present?
      self.interval_costs = serialized_interval_costs.split
    end
  end

  def serialize_occupation_costs
    self.serialized_occupation_costs = occupation_costs.drop(1).join(' ')
  end

  def serialize_blank_costs
    self.serialized_blank_costs = blank_costs.drop(1).join(' ')
  end

  def serialize_interval_costs
    self.serialized_interval_costs = interval_costs.join(' ')
  end
end
