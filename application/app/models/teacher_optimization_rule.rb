class TeacherOptimizationRule < ApplicationRecord
  belongs_to :term

  validates :single_cost,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :different_pair_cost,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :occupation_limit,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :occupation_costs,
            presence: true
  validates :blank_limit,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :blank_costs,
            presence: true

  validate :occupation_costs_valid?
  validate :blank_costs_valid?

  private

  def occupation_costs_valid?
    unless occupation_costs.length == occupation_limit + 1
      errors[:base] << '１日の最大コマ数に対するコスト値の設定数が間違えています'
    end
  end

  def blank_costs_valid?
    unless blank_costs.length == blank_limit + 1
      errors[:base] << '１日の空きコマ数に対するコスト値の設定数が間違えています'
    end
  end
end
