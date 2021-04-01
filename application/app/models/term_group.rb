class TermGroup < ApplicationRecord
  belongs_to :term
  belongs_to :group
  belongs_to :term_teacher, optional: true
  has_many :group_contracts, dependent: :restrict_with_exception
  has_many :timetables, dependent: :nullify

  validate :verify_daily_occupation_limit,
            on: :update,
            if: :will_save_change_to_term_teacher_id?

  before_validation :fetch_term_teacher_in_database, on: :update
  before_validation :fetch_tutorial_contracts_group_by_teacher_and_timetable, on: :update
  before_validation :fetch_new_group_contracts_group_by_teacher_and_timetable, on: :update
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
  def term_teacher_daily_occupations(date_index)
    tutorials = @tutorial_contracts_group_by_teacher_and_timetable.dig(term_teacher_id, date_index).to_h
    groups = @new_group_contracts_group_by_teacher_and_timetable.dig(term_teacher_id, date_index).to_h
    self.class.daily_occupations_from(tutorials.merge(groups) { |_k, v1, v2| v1.to_a + v2.to_a })
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
    tutorials = @tutorial_contracts_group_by_teacher_and_timetable.dig(term_teacher_id, date_index).to_h
    groups = @new_group_contracts_group_by_teacher_and_timetable.dig(term_teacher_id, date_index).to_h
    self.class.daily_blanks_from(tutorials.merge(groups) { |_k, v1, v2| v1.to_a + v2.to_a })
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
    tutorials = @tutorial_contracts_group_by_teacher_and_timetable.dig(term_teacher_id_in_database, date_index).to_h
    groups = @new_group_contracts_group_by_teacher_and_timetable.dig(term_teacher_id_in_database, date_index).to_h
    self.class.daily_blanks_from(tutorials.merge(groups) { |_k, v1, v2| v1.to_a + v2.to_a })
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

  def fetch_tutorial_contracts_group_by_teacher_and_timetable
    @tutorial_contracts_group_by_teacher_and_timetable =
      TutorialContract.group_by_teacher_and_timetable(term)
  end

  def new_term_groups
    term
      .term_groups
      .left_joins(:timetables)
      .pluck(:id, :term_teacher_id, :date_index, :period_index)
      .map { |item| [:id, :term_teacher_id, :date_index, :period_index].zip(item).to_h }
      .map do |item|
        {
          id: item[:id],
          term_teacher_id: item[:id] == id ? term_teacher_id : item[:term_teacher_id],
          date_index: item[:date_index],
          period_index: item[:period_index],
        }
      end
  end
  
  def fetch_new_group_contracts_group_by_teacher_and_timetable
    @new_group_contracts_group_by_teacher_and_timetable = 
      new_term_groups.reduce({}) do |accu, item|
        accu.deep_merge({
          item[:term_teacher_id] => {
            item[:date_index] => {
              item[:period_index] => item
            }
          }
        })
      end
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
