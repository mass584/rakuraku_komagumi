class Seat < ApplicationRecord
  belongs_to :term
  belongs_to :timetable
  belongs_to :term_teacher, optional: true
  has_many :tutorial_pieces, dependent: :destroy

  validates :seat_index,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :position_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validate :verify_timetable,
           on: :update,
           if: :will_save_change_to_term_teacher_id?
  validate :verify_doublebooking,
           on: :update,
           if: :will_save_change_to_term_teacher_id?
  validate :verify_daily_occupation_limit,
           on: :update,
           if: :will_save_change_to_term_teacher_id?
  validate :verify_daily_blank_limit,
           on: :update,
           if: :will_save_change_to_term_teacher_id?
  
  scope :filter_by_teachers, lambda { |term_teacher_ids|
    itself.where(term_teacher_id: term_teacher_ids)
  }

  def self.overwrite_term_teacher_id(id, term_teacher_id)
    itself.map do |item|
      item.term_teacher_id = term_teacher_id if item.id == id
      item
    end
  end

  def self.group_by_teacher_and_date_and_period
    itself.group_by_recursive(
      proc { |item| item.term_teacher_id },
      proc { |item| item.timetable.date_index },
      proc { |item| item.timetable.period_index },
    )
  end

  def self.position_occupations(term_teacher_id, timetable)
    itself
      .group_by_teacher_and_date_and_period
      .dig(term_teacher_id, timetable.date_index, timetable.period_index)
      .count
  end

  def self.daily_occupations(term_teacher_id, timetable)
    tutorials = itself
      .group_by_teacher_and_date_and_period
      .dig(term_teacher_id, timetable.date_index)
    groups = timetable.term.group_contracts
      .filter_by_teacher(term_teacher_id)
      .group_by_date_and_period
      .dig(timetable.date_index)
    self.class.daily_occupations_from(tutorials.deep_merge(groups))
  end

  def self.daily_blanks(term_teacher_id, timetable)
    tutorials = itself
      .group_by_teacher_and_date_and_period
      .dig(term_teacher_id, timetable.date_index)
    groups = timetable.term.group_contracts
      .filter_by_teacher(term_teacher_id)
      .group_by_date_and_period
      .dig(timetable.date_index)
    self.class.daily_blanks_from(tutorials.deep_merge(groups))
  end

  private

  def term_teacher_creation?
    term_teacher_id_in_database.nil? && term_teacher_id.present?
  end

  def term_teacher_updation?
    term_teacher_id_in_database.present? && term_teacher_id.present? && term_teacher_id_in_database != term_teacher_id
  end

  def term_teacher_deletion?
    term_teacher_id_in_database.present? && term_teacher_id.nil?
  end

  def new_seats
    term
      .seats
      .filter_by_teachers([term_teacher_id, term_teacher_id_in_database])
      .overwrite_term_teacher_id(id, term_teacher_id)
  end

  # validate
  def verify_timetable
    if term_teacher_creation? && timetable.term_group_id.present?
      errors[:base] << '集団科目が割り当てられています'
    end

    if term_teacher_creation? && timetable.is_closed
      errors[:base] << '休講に設定されています'
    end
  end

  def verify_doublebooking
    if term_teacher_creation? && new_seats.position_occupations(term_teacher_id, timetable) > 1
      errors[:base] << '講師の予定が重複しています'
    end

    if term_teacher_updation? && new_seats.position_occupations(term_teacher_id, timetable) > 1
      errors[:base] << '講師の予定が重複しています'
    end
  end

  def verify_daily_occupation_limit
    if seat_creation? &&
       new_seats.daily_occupations(term_teacher_id, timetable) > term_teacher.optimization_rule.occupation_limit
      errors[:base] << '講師の合計コマの上限を超えています'
    end

    if seat_updation? &&
       new_seats.daily_occupations(term_teacher_id, timetable) > term_teacher.optimization_rule.occupation_limit
      errors[:base] << '講師の合計コマの上限を超えています'
    end
  end

  def verify_daily_blank_limit
    if seat_creation? &&
       new_seats.daily_blanks(term_teacher_id, timetable) > term_teacher.optimization_rule.blank_limit
      errors[:base] << '講師の空きコマの上限（２コマ）を超えています'
    end

    if seat_updation? && (
      new_seats.daily_blanks(term_teacher_id, timetable) > term_teacher.optimization_rule.blank_limit || 
      new_seats.daily_blanks(term_teacher_id_in_database, timetable) > term_teacher.optimization_rule.blank_limit
    )
      errors[:base] << '講師の空きコマの上限（２コマ）を超えています'
    end

    if seat_deletion? &&
       new_seats.daily_blanks(term_teacher_id_in_database, timetable) > term_teacher.optimization_rule.blank_limit
      errors[:base] << '講師の空きコマの上限（２コマ）を超えています'
    end
  end
end
