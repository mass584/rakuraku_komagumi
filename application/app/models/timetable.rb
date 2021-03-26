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

  accepts_nested_attributes_for :seats

  def self.new(attr = {})
    attr[:term_group_id] || = nil
    attr[:is_closed] || = false
    super(attr)
  end

  def occupated_seat_count
    seats.filter { |seat| seat.pieces.exists? }.count
  end

  private

  def can_update_is_closed?
    unless occupated_seat_count.zero?
      errors[:base] << '座席にコマが割り当てられているため変更できません'
    end
  end

  def can_update_term_group_id?
    # 追加・変更時、新規担当講師の空きコマ違反が発生しないか
    # 追加・変更時、新規担当講師の合計コマ違反が発生しないか
    # 削除・変更時、従来担当講師の空きコマ違反が発生しないか
  end
end
