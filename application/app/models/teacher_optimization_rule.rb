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
  validates :serialized_occupation_costs,
            format: { with: /\A[0-9\s]*\Z/, message: 'の形式が誤っています' },
            allow_nil: true
  validates :blank_limit,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :blank_costs,
            presence: true
  validates :serialized_blank_costs,
            format: { with: /\A[0-9\s]*\Z/, message: 'の形式が誤っています' },
            allow_nil: true

  validate :tutorial_piece_empty?
  validate :occupation_costs_valid?
  validate :blank_costs_valid?

  before_validation :deserialize_occupation_costs
  before_validation :deserialize_blank_costs
  after_find :serialize_occupation_costs
  after_find :serialize_blank_costs

  attr_accessor :serialized_occupation_costs,
                :serialized_blank_costs

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
      errors.add(:base, '１日の最大コマ数に対するコスト値の設定数が間違えています')
    end
  end

  def blank_costs_valid?
    unless blank_costs.length == blank_limit + 1
      errors.add(:base, '１日の空きコマ数に対するコスト値の設定数が間違えています')
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

  def serialize_occupation_costs
    self.serialized_occupation_costs = occupation_costs.drop(1).join(' ')
  end

  def serialize_blank_costs
    self.serialized_blank_costs = blank_costs.drop(1).join(' ')
  end
end
