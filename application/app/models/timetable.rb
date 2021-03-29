class Timetable < ApplicationRecord
  belongs_to :term
  belongs_to :term_groups, optional: true
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

  before_save :set_nest_objects

  def self.new(attributes = {})
    attributes[:is_closed] ||= false
    super(attributes)
  end

  def occupated_seat_count
    seats.filter { |seat| seat.pieces.exists? }.count
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
    unless occupated_seat_count.zero?
      errors[:base] << '個別授業が割り当てられているため変更できません'
    end

    unless term_group_id.nil?
      errors[:base] << '集団授業が割り当てられているため変更できません'
    end
  end

  def can_update_term_group_id?
    # 追加・変更時、新規担当講師の空きコマ違反が発生しないか
    # 追加・変更時、新規担当講師の合計コマ違反が発生しないか
    # 削除・変更時、従来担当講師の空きコマ違反が発生しないか
  end
end
