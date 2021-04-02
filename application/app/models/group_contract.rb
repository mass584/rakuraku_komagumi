class GroupContract < ApplicationRecord
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

  scope :filter_by_is_contracted, lambda {
    itself.where(is_contracted: true)
  }
  scope :filter_by_student, lambda { |term_student_id|
    itself.where(term_student_id: term_student_id)
  }
  scope :filter_by_teacher, lambda { |term_teacher_id|
    itself.joins(:term_group).where('term_groups.term_teacher_id': term_teacher_id)
  }

  before_validation :fetch_new_group_contracts, on: :update
  before_validation :fetch_new_group_contracts_group_by_timetable, on: :update
  before_validation :fetch_tutorial_contracts_group_by_timetable, on: :update

  def self.new(attributes = {})
    attributes[:is_contracted] ||= false
    super(attributes)
  end

  def self.group_by_timetable_for_teacher(term, term_teacher_id)
    records = term
      .group_contracts
      .filter_by_teacher(term_teacher_id)
      .joins(term_group: :timetables)
      .select("timetables.*")
    term.timetables.pluck(:id, :date_index, :period_index, :term_group_id).reduce({}) do |accu, timetable|
      accu.deep_merge({
        timetable[1] => {
          timetable[2] => 
            records.filter { |record| record.term_group_id == timetable[3] },
        }
      })
    end
  end

  def self.group_by_timetable_for_student(term, term_student_id)
    records = term
      .group_contracts
      .filter_by_student(term_student_id)
      .filter_by_is_contracted
      .joins(term_group: :timetables)
      .select("timetables.*")
    term.timetables.pluck(:id, :date_index, :period_index, :term_group_id).reduce({}) do |accu, timetable|
      accu.deep_merge({
        timetable[1] => {
          timetable[2] => 
            records.filter { |record| record.term_group_id == timetable[3] },
        }
      })
    end
  end

  private

  def contract_creation?
    !is_contracted_in_database && is_contracted
  end

  # validate
  def daily_occupations(date_index)
    tutorials = @tutorial_contracts_group_by_timetable.dig(date_index).to_h
    groups = @new_group_contracts_group_by_timetable.dig(date_index).to_h
    tutorials_and_groups = self.class.merge_tutorials_and_groups(term, tutorials, groups)
    self.class.daily_occupations_from(tutorials_and_groups)
  end

  def verify_daily_occupation_limit
    date_indexes = term_group.timetables.pluck(:date_index).uniq
    occupation_limit = term_student.optimization_rule.occupation_limit
    daily_occupations_invalid = date_indexes.reduce(false) do |accu, date_index|
      accu || daily_occupations(date_index) > occupation_limit
    end

    if contract_creation? && daily_occupations_invalid
      errors[:base] << '生徒の１日の合計コマの上限を超えています'
    end
  end

  def daily_blanks(date_index)
    tutorials = @tutorial_contracts_group_by_timetable.dig(date_index).to_h
    groups = @new_group_contracts_group_by_timetable.dig(date_index).to_h
    tutorials_and_groups = self.class.merge_tutorials_and_groups(term, tutorials, groups)
    self.class.daily_blanks_from(tutorials_and_groups)
  end

  def verify_daily_blank_limit
    date_indexes = term_group.timetables.pluck(:date_index).uniq
    blank_limit = term_student.optimization_rule.blank_limit
    daily_blanks_invalid = date_indexes.reduce(false) do |accu, date_index|
      accu || daily_blanks(date_index) > blank_limit
    end

    if daily_blanks_invalid
      errors[:base] << '生徒の１日の空きコマの上限を超えています'
    end
  end

  # before_validation
  def fetch_new_group_contracts
    @new_group_contracts = term
      .group_contracts
      .filter_by_student(term_student_id)
      .pluck(:id, :term_group_id, :is_contracted)
      .map { |item| [:id, :term_group_id, :is_contracted].zip(item).to_h }
      .map do |item|
        {
          id: item[:id],
          term_group_id: item[:term_group_id],
          is_contracted: item[:id] == id ? is_contracted : item[:is_contracted],
        }
      end 
  end

  def selected_new_group_contracts(term_group_id)
    @new_group_contracts.select do |new_group_contract|
      new_group_contract[:term_group_id] == term_group_id && new_group_contract[:is_contracted]
    end
  end

  def fetch_new_group_contracts_group_by_timetable
    timetables = term.timetables.pluck(:date_index, :period_index, :term_group_id).map do |item|
      [:date_index, :period_index, :term_group_id].zip(item).to_h
    end
    @new_group_contracts_group_by_timetable = timetables.reduce({}) do |accu, timetable|
      accu.deep_merge({
        timetable[:date_index] => {
          timetable[:period_index] => selected_new_group_contracts(timetable[:term_group_id]),
        }
      })
    end
  end

  def fetch_tutorial_contracts_group_by_timetable
    @tutorial_contracts_group_by_timetable = TutorialContract.group_by_timetable_for_student(term, term_student_id)
  end
end
