class TermGroup < ApplicationRecord
  belongs_to :term
  belongs_to :group
  belongs_to :term_teacher, optional: true
  has_many :group_contracts, dependent: :restrict_with_exception
  has_many :timetables, dependent: :nullify

  validate :verify_daily_occupation_limit,
            on: :update,
            if: :will_save_change_to_term_teacher_id?
  validate :verify_daily_blank_limit_for_creation,
            on: :update,
            if: :will_save_change_to_term_teacher_id?
  validate :verify_daily_blank_limit_for_deletion,
            on: :update,
            if: :will_save_change_to_term_teacher_id?

  before_validation :fetch_term_teacher_in_database, on: :update
  before_validation :fetch_tutorials_group_by_teacher_and_timetable, on: :update
  before_validation :fetch_new_groups_group_by_teacher_and_timetable, on: :update
  before_create :set_nest_objects

  private

  def term_teacher_creation?
    !term_teacher_id_in_database && term_teacher_id
  end

  def term_teacher_updateion?
    term_teacher_id_in_database && term_teacher_id && (term_teacher_id_in_database != term_teacher_id)
  end

  def term_teacher_deletion?
    term_teacher_id_in_database && !term_teacher_id
  end

  # validate
  def daily_occupations(date_index)
    tutorials = @tutorials_group_by_teacher_and_timetable.dig(term_teacher_id, date_index).to_h
    groups = @new_groups_group_by_teacher_and_timetable.dig(term_teacher_id, date_index).to_h
    tutorials_and_groups = self.class.merge_tutorials_and_groups(term, tutorials, groups)
    self.class.daily_occupations_from(tutorials_and_groups)
  end

  def verify_daily_occupation_limit
    return if term_teacher_deletion?
    date_indexes = timetables.pluck(:date_index).uniq
    occupation_limit = term_teacher.optimization_rule.occupation_limit
    daily_occupations_invalid = date_indexes.reduce(false) do |accu, date_index|
      accu || daily_occupations(date_index) > occupation_limit
    end
    if daily_occupations_invalid
      errors[:base] << '講師の１日の合計コマの上限を超えています'
    end
  end

  def term_teacher_for_creation_daily_blanks(date_index)
    tutorials = @tutorials_group_by_teacher_and_timetable.dig(term_teacher_id, date_index).to_h
    groups = @new_groups_group_by_teacher_and_timetable.dig(term_teacher_id, date_index).to_h
    tutorials_and_groups = self.class.merge_tutorials_and_groups(term, tutorials, groups)
    self.class.daily_blanks_from(tutorials_and_groups)
  end

  def verify_daily_blank_limit_for_creation
    return if term_teacher_deletion?
    date_indexes = timetables.pluck(:date_index).uniq
    blank_limit = term_teacher.optimization_rule.blank_limit
    daily_blanks_invalid = date_indexes.reduce(false) do |accu, date_index|
      accu || term_teacher_for_creation_daily_blanks(date_index) > blank_limit
    end
    if daily_blanks_invalid
      errors[:base] << '講師の１日の空きコマの上限を超えています'
    end
  end

  def term_teacher_for_deletion_daily_blanks(date_index)
    tutorials = @tutorials_group_by_teacher_and_timetable.dig(term_teacher_id_in_database, date_index).to_h
    groups = @new_groups_group_by_teacher_and_timetable.dig(term_teacher_id_in_database, date_index).to_h
    tutorials_and_groups = self.class.merge_tutorials_and_groups(term, tutorials, groups)
    self.class.daily_blanks_from(tutorials_and_groups)
  end

  def verify_daily_blank_limit_for_deletion
    return if term_teacher_creation?
    date_indexes = timetables.pluck(:date_index).uniq
    blank_limit = @term_teacher_in_database.optimization_rule.blank_limit
    daily_blanks_invalid = date_indexes.reduce(false) do |accu, date_index|
      accu || term_teacher_for_deletion_daily_blanks(date_index) > blank_limit
    end
    if daily_blanks_invalid
      errors[:base] << '講師の１日の空きコマの上限を超えています'
    end
  end

  # before_validation
  def fetch_term_teacher_in_database
    @term_teacher_in_database = TermTeacher.find_by(id: term_teacher_id_in_database)
  end

  def fetch_tutorials_group_by_teacher_and_timetable
    records = term
      .tutorial_contracts
      .joins(tutorial_pieces: [seat: :timetable])
      .select(:term_teacher_id, :date_index, :period_index)
    @tutorials_group_by_teacher_and_timetable = records.group_by_recursive(
      proc { |item| item[:term_teacher_id] },
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  def fetch_new_groups_group_by_teacher_and_timetable
    records = term
      .term_groups
      .left_joins(:timetables)
      .select(:id, :term_teacher_id, :date_index, :period_index)
      .map do |item|
        {
          id: item[:id],
          term_teacher_id: item[:id] == id ? term_teacher_id : item[:term_teacher_id],
          date_index: item[:date_index],
          period_index: item[:period_index],
        }
      end
      .select { |record| record[:term_teacher_id].present? }
    @new_groups_group_by_teacher_and_timetable = records.group_by_recursive(
      proc { |item| item[:term_teacher_id] },
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  # before_create
  def set_nest_objects
    self.group_contracts = new_group_contracts
  end

  def new_group_contracts 
    term.term_students.map do |term_student|
      GroupContract.new({ term_id: term.id, term_student_id: term_student.id })
    end
  end
end
