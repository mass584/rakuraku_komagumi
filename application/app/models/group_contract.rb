class GroupContract < ApplicationRecord
  extend OccupationsBlanks

  belongs_to :term
  belongs_to :term_student
  belongs_to :term_group

  validates :is_contracted,
            exclusion: { in: [nil], message: 'にnilは許容されません' }

  validate :verify_daily_occupation_limit,
           on: :update,
           if: :will_save_change_to_is_contracted?
  validate :verify_daily_blank_limit,
           on: :update,
           if: :will_save_change_to_is_contracted?

  before_validation :fetch_tutorials_group_by_timetable, on: :update
  before_validation :fetch_new_groups_group_by_timetable, on: :update

  scope :filter_by_is_contracted, lambda {
    itself.where(is_contracted: true)
  }
  scope :filter_by_student, lambda { |term_student_id|
    itself.where(term_student_id: term_student_id)
  }

  def self.new(attributes = {})
    attributes[:is_contracted] ||= false
    super(attributes)
  end

  private

  def contract_creation?
    !is_contracted_in_database && is_contracted
  end

  # validate
  def daily_occupations(date_index)
    tutorials = @tutorials_group_by_timetable[date_index].to_h
    groups = @new_groups_group_by_timetable[date_index].to_h
    self.class.daily_occupations_from(term, tutorials, groups)
  end

  def verify_daily_occupation_limit
    date_indexes = term_group.timetables.pluck(:date_index).uniq
    occupation_limit = term_student.optimization_rule.occupation_limit
    daily_occupations_invalid = date_indexes.reduce(false) do |accu, date_index|
      accu || daily_occupations(date_index) > occupation_limit
    end

    if contract_creation? && daily_occupations_invalid
      errors.add(:base, '生徒の１日の合計コマの上限を超えています')
    end
  end

  def daily_blanks(date_index)
    tutorials = @tutorials_group_by_timetable[date_index].to_h
    groups = @new_groups_group_by_timetable[date_index].to_h
    self.class.daily_blanks_from(term, tutorials, groups)
  end

  def verify_daily_blank_limit
    date_indexes = term_group.timetables.pluck(:date_index).uniq
    blank_limit = term_student.optimization_rule.blank_limit
    daily_blanks_invalid = date_indexes.reduce(false) do |accu, date_index|
      accu || daily_blanks(date_index) > blank_limit
    end

    if daily_blanks_invalid
      errors.add(:base, '生徒の１日の空きコマの上限を超えています')
    end
  end

  # before_validation
  def fetch_new_groups_group_by_timetable
    records = term
              .group_contracts
              .filter_by_student(term_student_id)
              .joins(term_group: :timetables)
              .select(:id, :term_group_id, :is_contracted, :date_index, :period_index)
              .map do |item|
                {
                  id: item[:id],
                  term_group_id: item[:term_group_id],
                  is_contracted: item[:id] == id ? is_contracted : item[:is_contracted],
                  date_index: item[:date_index],
                  period_index: item[:period_index],
                }
              end
              .select { |item| item[:is_contracted] }
    @new_groups_group_by_timetable = records.group_by_recursive(
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  def fetch_tutorials_group_by_timetable
    records = term
              .tutorial_contracts
              .filter_by_student(term_student_id)
              .joins(tutorial_pieces: [seat: :timetable])
              .select(:date_index, :period_index)
    @tutorials_group_by_timetable = records.group_by_recursive(
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end
end
