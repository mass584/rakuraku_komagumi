class Timetable < ApplicationRecord
  belongs_to :term
  belongs_to :term_group, optional: true
  has_many :student_vacancies, dependent: :destroy
  has_many :teacher_vacancies, dependent: :destroy
  has_many :seats, dependent: :destroy

  validates :date_index,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :period_index,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :is_closed,
            exclusion: { in: [nil], message: 'にnilは許容されません' }

  validate :can_update_is_closed?,
           on: :update,
           if: :will_save_change_to_is_closed?
  validate :can_update_term_group_id?,
           on: :update,
           if: :will_save_change_to_term_group_id?

  scope :ordered, -> { order(date_index: 'ASC', period_index: 'ASC') }

  before_create :set_nest_objects

  def self.new(attributes = {})
    attributes[:is_closed] ||= false
    super(attributes)
  end

  private

  # callback
  def set_nest_objects
    self.seats.build(new_seats)
  end

  def new_seats
    term.seat_index_array.map do |index|
      { term_id: term.id, seat_index: index, position_count: term.position_count }
    end
  end

  # validate
  def can_update_is_closed?
    if is_closed && seats.filter_by_occupied.count.positive?
      errors.add(:base, '個別授業が割り当てられているため変更できません')
    end

    if is_closed && term_group_id.present?
      errors.add(:base, '集団授業が割り当てられているため変更できません')
    end
  end

  def can_update_term_group_id?
    if term_group_id.present? && seats.filter_by_occupied.count.positive?
      errors.add(:base, '個別授業が割り当てられているため変更できません')
    end

    if term_group_id.present? && is_closed
      errors.add(:base, '休講のため変更できません')
    end
  end
end
