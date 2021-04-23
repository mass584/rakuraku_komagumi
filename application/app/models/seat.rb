class Seat < ApplicationRecord
  extend OccupationsBlanks

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
  validate :verify_teacher_vacancy,
           on: :update,
           if: :will_save_change_to_term_teacher_id?
  validate :verify_doublebooking,
           on: :update,
           if: :will_save_change_to_term_teacher_id?
  validate :verify_daily_occupation_limit,
           on: :update,
           if: :will_save_change_to_term_teacher_id?
  validate :verify_daily_blank_limit_for_creation,
           on: :update,
           if: :validate_without_intermediate_state?
  validate :verify_daily_blank_limit_for_deletion,
           on: :update,
           if: :validate_without_intermediate_state?

  before_validation :fetch_term_teacher_in_database, on: :update
  before_validation :fetch_new_tutorials_group_by_teacher_and_timetable, on: :update
  before_validation :fetch_groups_group_by_teacher_and_timetable, on: :update

  scope :filter_by_occupied, lambda {
    where.not(term_teacher_id: nil)
  }
  scope :with_group, lambda {
    left_joins(timetable: [term_group: [:group]]).select('timetables.*', 'groups.name AS group_name')
  }
  scope :with_index, lambda {
    joins(:timetable).select('timetables.*', 'seats.seat_index')
  }

  # トランザクションの途中、中間状態のバリデーションをスキップして一時的にバリデーション違反を許容させるためのフラグ
  attr_accessor :skip_intermediate_state_validation

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

  def validate_without_intermediate_state?
    will_save_change_to_term_teacher_id? && !@skip_intermediate_state_validation
  end

  # validate
  def verify_timetable
    if term_teacher_creation? && timetable.term_group_id.present?
      errors.add(:base, '集団科目が割り当てられています')
    end

    if term_teacher_creation? && timetable.is_closed
      errors.add(:base, '休講に設定されています')
    end
  end

  def verify_teacher_vacancy
    if (term_teacher_creation? || term_teacher_updation?) &&
       !timetable.teacher_vacancies.find_by(term_teacher_id: term_teacher_id).is_vacant
      errors.add(:base, '講師の予定が空いていません')
    end
  end

  def position_occupations(term_teacher_id, timetable)
    @new_tutorials_group_by_teacher_and_timetable
      .dig(term_teacher_id, timetable.date_index, timetable.period_index).to_a.count
  end

  def verify_doublebooking
    if term_teacher_creation? && position_occupations(term_teacher_id, timetable) > 1
      errors.add(:base, '講師の予定が重複しています')
    end

    if term_teacher_updation? && position_occupations(term_teacher_id, timetable) > 1
      errors.add(:base, '講師の予定が重複しています')
    end
  end

  def daily_occupations
    tutorials = @new_tutorials_group_by_teacher_and_timetable
      .dig(term_teacher_id, timetable.date_index).to_h
    groups = @groups_group_by_teacher_and_timetable
      .dig(term_teacher_id, timetable.date_index).to_h
    self.class.daily_occupations_from(term, tutorials, groups)
  end

  def verify_daily_occupation_limit
    if (term_teacher_creation? || term_teacher_updation?) &&
       daily_occupations > term_teacher.optimization_rule.occupation_limit
      errors.add(:base, '講師の１日の合計コマの上限を超えています')
    end
  end

  def daily_blanks_for_creation
    tutorials = @new_tutorials_group_by_teacher_and_timetable
      .dig(term_teacher_id, timetable.date_index).to_h
    groups = @groups_group_by_teacher_and_timetable
      .dig(term_teacher_id, timetable.date_index).to_h
    self.class.daily_blanks_from(term, tutorials, groups)
  end

  def verify_daily_blank_limit_for_creation
    if (term_teacher_creation? || term_teacher_updation?) &&
       daily_blanks_for_creation > term_teacher.optimization_rule.blank_limit
      errors.add(:base, '講師の１日の空きコマの上限を超えています')
    end
  end

  def daily_blanks_for_deletion
    tutorials = @new_tutorials_group_by_teacher_and_timetable
      .dig(term_teacher_id_in_database, timetable.date_index).to_h
    groups = @groups_group_by_teacher_and_timetable
      .dig(term_teacher_id_in_database, timetable.date_index).to_h
    self.class.daily_blanks_from(term, tutorials, groups)
  end

  def verify_daily_blank_limit_for_deletion
    if (term_teacher_updation? || term_teacher_deletion?) &&
       daily_blanks_for_deletion > @term_teacher_in_database.optimization_rule.blank_limit
      errors.add(:base, '講師の１日の空きコマの上限を超えています')
    end
  end

  # before_validation
  def fetch_term_teacher_in_database
    @term_teacher_in_database = TermTeacher.find_by(id: term_teacher_id_in_database)
  end

  def fetch_new_tutorials_group_by_teacher_and_timetable
    records = term.seats.joins(:timetable)
      .select(:id, :term_teacher_id, :date_index, :period_index)
      .map do |item|
        {
          id: item[:id],
          term_teacher_id: item[:id] == id ? term_teacher_id : item[:term_teacher_id],
          date_index: item[:date_index],
          period_index: item[:period_index],
        }
      end
      .select { |item| item[:term_teacher_id].present? }
    @new_tutorials_group_by_teacher_and_timetable = records.group_by_recursive(
      proc { |item| item[:term_teacher_id] },
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  def fetch_groups_group_by_teacher_and_timetable
    records = term.timetables.joins(:term_group)
      .select(:term_teacher_id, :date_index, :period_index)
      .select { |item| item[:term_teacher_id].present? }
    @groups_group_by_teacher_and_timetable = records.group_by_recursive(
      proc { |item| item[:term_teacher_id] },
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end
end
