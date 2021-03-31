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
    where(term_teacher_id: term_teacher_ids)
  }
  scope :filter_by_occupied, lambda {
    where.not(term_teacher_id: nil)
  }

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

  def term_teacher_in_database
    @term_teacher_in_database ||= (TermTeacher.find_by(id: term_teacher_id_in_database) || TermTeacher.new)
  end

  # Seat array's dataflow
  def new_seats
    term
      .seats
      .filter_by_teachers([term_teacher_id, term_teacher_id_in_database])
      .map { |item| item.term_teacher_id = term_teacher_id if item.id == id; item }
  end

  def group_by_teacher_and_date_and_period
    new_seats.group_by_recursive(
      proc { |item| item.term_teacher_id },
      proc { |item| item.timetable.date_index },
      proc { |item| item.timetable.period_index },
    )
  end

  def position_occupations(term_teacher_id, timetable)
    (group_by_teacher_and_date_and_period
      .dig(term_teacher_id, timetable.date_index, timetable.period_index) || [])
      .count
  end

  def daily_occupations(term_teacher_id, timetable)
    tutorials = group_by_teacher_and_date_and_period.dig(term_teacher_id, timetable.date_index).to_h
    groups = GroupContract.group_by_date_and_period(
      timetable.term.group_contracts.filter_by_teacher(term_teacher_id),
      term,
    ).dig(timetable.date_index).to_h
    self.class.daily_occupations_from(tutorials.merge(groups) { |_k, v1, v2| v1.to_a + v2.to_a })
  end

  def daily_blanks(term_teacher_id, timetable)
    tutorials = group_by_teacher_and_date_and_period.dig(term_teacher_id, timetable.date_index).to_h
    groups = GroupContract.group_by_date_and_period(
      timetable.term.group_contracts.filter_by_teacher(term_teacher_id),
      term,
    ).dig(timetable.date_index).to_h
    self.class.daily_blanks_from(tutorials.merge(groups) { |_k, v1, v2| v1.to_a + v2.to_a })
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
    if term_teacher_creation? && position_occupations(term_teacher_id, timetable) > 1
      errors[:base] << '講師の予定が重複しています'
    end

    if term_teacher_updation? && position_occupations(term_teacher_id, timetable) > 1
      errors[:base] << '講師の予定が重複しています'
    end
  end

  def verify_daily_occupation_limit
    if term_teacher_creation? &&
       daily_occupations(term_teacher_id, timetable) > term_teacher.optimization_rule.occupation_limit
      errors[:base] << '講師の１日の合計コマの上限を超えています'
    end

    if term_teacher_updation? &&
       daily_occupations(term_teacher_id, timetable) > term_teacher.optimization_rule.occupation_limit
      errors[:base] << '講師の１日の合計コマの上限を超えています'
    end
  end

  def verify_daily_blank_limit
    if term_teacher_creation? &&
       daily_blanks(term_teacher_id, timetable) > term_teacher.optimization_rule.blank_limit
      errors[:base] << '講師の１日の空きコマの上限を超えています'
    end

    if term_teacher_updation? && (
      daily_blanks(term_teacher_id, timetable) > term_teacher.optimization_rule.blank_limit || 
      daily_blanks(term_teacher_id_in_database, timetable) > term_teacher_in_database.optimization_rule.blank_limit
    )
      errors[:base] << '講師の１日の空きコマの上限を超えています'
    end

    if term_teacher_deletion? &&
       daily_blanks(term_teacher_id_in_database, timetable) > term_teacher_in_database.optimization_rule.blank_limit
      errors[:base] << '講師の１日の空きコマの上限を超えています'
    end
  end
end
