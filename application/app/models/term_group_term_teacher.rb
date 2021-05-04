class TermGroupTermTeacher < ApplicationRecord
  extend OccupationsBlanks
  belongs_to :term_group
  belongs_to :term_teacher

  validate :verify_daily_occupation_limit, on: :create
  validate :verify_daily_blank_limit_on_create, on: :create

  before_validation :fetch_tutorials_group_by_timetable
  before_validation :fetch_groups_group_by_timetable_on_create, on: :create

  before_destroy :fetch_groups_group_by_timetable_on_destroy
  before_destroy :verify_daily_blank_limit_on_destroy

  private

  # validate
  def daily_occupations(date_index)
    tutorials = @tutorials_group_by_timetable[date_index].to_h
    groups = @groups_group_by_timetable[date_index].to_h
    self.class.daily_occupations_from(term_group.term, tutorials, groups)
  end

  def verify_daily_occupation_limit
    date_indexes = term_group.timetables.pluck(:date_index).uniq
    occupation_limit = term_teacher.optimization_rule.occupation_limit
    invalid = date_indexes.reduce(false) do |accu, date_index|
      accu || daily_occupations(date_index) > occupation_limit
    end
    if invalid
      errors.add(:base, '講師の１日の合計コマの上限を超えています')
    end
  end

  def term_teacher_daily_blanks(date_index)
    tutorials = @tutorials_group_by_timetable[date_index].to_h
    groups = @groups_group_by_timetable[date_index].to_h
    self.class.daily_blanks_from(term_group.term, tutorials, groups)
  end

  def verify_daily_blank_limit_on_create
    date_indexes = term_group.timetables.pluck(:date_index).uniq
    blank_limit = term_teacher.optimization_rule.blank_limit
    invalid = date_indexes.reduce(false) do |accu, date_index|
      accu || term_teacher_daily_blanks(date_index) > blank_limit
    end
    if invalid
      errors.add(:base, '講師の１日の空きコマの上限を超えています')
    end
  end

  # before_validation
  def fetch_tutorials_group_by_timetable
    records = term_group
              .term
              .tutorial_contracts
              .joins(tutorial_pieces: [seat: :timetable])
              .where('seats.term_teacher_id': term_teacher_id)
              .select(:term_tutorial_id, :date_index, :period_index)
    @tutorials_group_by_timetable = records.group_by_recursive(
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  def fetch_groups_group_by_timetable_on_create
    old_records = term_group
                  .term
                  .timetables
                  .joins(term_group: :term_group_term_teachers)
                  .where('term_group_term_teachers.term_teacher_id': term_teacher_id)
                  .select(:term_group_id, :date_index, :period_index)
    new_records = term_group.timetables.map do |timetable|
      {
        term_group_id: term_group_id,
        date_index: timetable.date_index,
        period_index: timetable.period_index,
      }
    end
    records = old_records + new_records
    @groups_group_by_timetable = records.group_by_recursive(
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  def fetch_groups_group_by_timetable_on_destroy
    records = term_group
              .term
              .timetables
              .joins(term_group: :term_group_term_teachers)
              .where('term_group_term_teachers.term_teacher_id': term_teacher_id)
              .select(:term_group_id, :date_index, :period_index)
    filtered_records = records.filter do |record|
      record[:term_group_id] != term_group_id
    end
    @groups_group_by_timetable = filtered_records.group_by_recursive(
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  def verify_daily_blank_limit_on_destroy
    date_indexes = term_group.timetables.pluck(:date_index).uniq
    blank_limit = term_teacher.optimization_rule.blank_limit
    invalid = date_indexes.reduce(false) do |accu, date_index|
      accu || term_teacher_daily_blanks(date_index) > blank_limit
    end
    if invalid
      errors.add(:base, '講師の１日の空きコマの上限を超えています')
      throw :abort
    end
  end
end
