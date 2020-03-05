class CalculationRule < ApplicationRecord
  belongs_to :schedulemaster
  validates :schedulemaster_id,
            presence: true
  validates :eval_target,
            presence: true
  validates :total_class_cost,
            format: { with: /\A[0-9\,]*\z/, message: ':カンマ(,)で区切ってください' }
  validates :blank_class_cost,
            format: { with: /\A[0-9\,]*\z/, message: ':カンマ(,)で区切ってください' }
  validates :interval_cost,
            format: { with: /\A[0-9\,]*\z/, message: ':カンマ(,)で区切ってください' }
  validate :check_total_class_cost
  validate :check_blank_class_cost

  def self.bulk_create(schedulemaster)
    create(
      schedulemaster_id: schedulemaster.id,
      eval_target: 'teacher',
      single_cost: 100,
      different_pair_cost: 15,
      total_class_cost: '0,30,18,3,0,6,24',
      total_class_max: 6,
      blank_class_cost: '0,30',
      blank_class_max: 1,
      interval_cost: '0',
    )
    create(
      schedulemaster_id: schedulemaster.id,
      eval_target: 'student',
      single_cost: 0,
      different_pair_cost: 0,
      total_class_cost: '0,0,14,70',
      total_class_max: 3,
      blank_class_cost: '0,70',
      blank_class_max: 1,
      interval_cost: '70,35,14',
    )
    create(
      schedulemaster_id: schedulemaster.id,
      eval_target: 'student3g',
      single_cost: 0,
      different_pair_cost: 0,
      total_class_cost: '0,0,7,21,70',
      total_class_max: 4,
      blank_class_cost: '0,70',
      blank_class_max: 1,
      interval_cost: '70,35,14',
    )
  end

  def check_total_class_cost
    if total_class_cost.split(',').count != total_class_max + 1
      errors.add(:total_class_cost, '：コスト値の数が誤っています')
    end
  end

  def check_blank_class_cost
    if blank_class_cost.split(',').count != blank_class_max + 1
      errors.add(:blank_class_cost, '：コスト値の数が誤っています')
    end
  end
end
