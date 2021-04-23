class StudentOptimizationRule < ApplicationRecord
  belongs_to :term

  validates :occupation_limit,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :occupation_costs,
            presence: true
  validates :blank_limit,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :blank_costs,
            presence: true
  validates :interval_cutoff,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :interval_costs,
            presence: true

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

  validate :occupation_costs_valid?
  validate :blank_costs_valid?
  validate :interval_costs_valid?

  private

  def occupation_costs_valid?
    unless occupation_costs.length == occupation_limit + 1
      errors.add(:base, '１日の最大コマ数に対するコスト値の設定数が間違えています')
    end
  end

  def blank_costs_valid?
    unless blank_costs.length == blank_limit + 1
      errors.add(:base, '１日の空きコマ数に対するコスト値の設定数が間違えています')
    end
  end

  def interval_costs_valid?
    unless interval_costs.length == interval_cutoff + 1
      errors.add(:base, '科目の受講日数感覚に対するコスト値の設定数が間違えています')
    end
  end
end
