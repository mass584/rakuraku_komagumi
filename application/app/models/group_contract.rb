class GroupContract < ApplicationRecord
  belongs_to :term
  belongs_to :term_student
  belongs_to :term_group

  validates :is_contracted,
            exclusion: { in: [nil], message: 'にnilは許容されません' }

  validate :can_update_is_contracted,
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

  def self.new(attributes = {})
    attributes[:is_contracted] ||= false
    super(attributes)
  end

  def self.group_by_date_and_period(group_contracts, term)
    term.timetables.reduce({}) do |accu, timetable|
      accu.deep_merge({
        timetable.date_index => {
          timetable.period_index => filter_by_timetable(group_contracts, timetable),
        }
      })
    end
  end

  def self.filter_by_timetable(group_contracts, timetable)
    group_contracts.select do |group_contract|
      group_contract.term_group_id == timetable.term_group_id && group_contract.is_contracted
    end
  end

  private

  def contract_creation?
    !is_contracted_in_database && is_contracted
  end

  def seat_deletion?
    is_contracted_in_database && !is_contracted
  end

  # GroupContract array's dataflow
  def new_group_contracts
    term
      .group_contracts
      .filter_by_student(group_contract.term_student_id)
      .map { |item| item.is_contracted = is_contracted if item.id == id; item }
  end

  def group_by_date_and_period
    term.timetables.reduce({}) do |accu, timetable|
      accu.deep_merge({
        timetable.date_index => {
          timetable.period_index => group_contracts(timetable),
        }
      })
    end
  end

  def group_contracts(timetable)
    new_group_contracts.select do |group_contract|
      group_contract.term_group_id == timetable.term_group_id && group_contract.is_contracted
    end
  end

  def daily_occupations(term_student_id, timetable)
    tutorials = TutorialContract.group_by_date_and_period(
      timetable.term.tutorial_contracts.filter_by_student(term_student_id),
      term,
    ).dig(timetable.date_index).to_h
    groups = group_by_date_and_period.dig(timetable.date_index).to_h
    self.class.daily_occupations_from(tutorials.merge(groups) { |_k, v1, v2| v1.to_a + v2.to_a })
  end

  def daily_blanks(term_student_id, timetable)
    tutorials = TutorialContract.group_by_date_and_period(
      timetable.term.tutorial_contracts.filter_by_student(term_student_id),
      term,
    ).dig(timetable.date_index).to_h
    groups = group_by_date_and_period.dig(timetable.date_index).to_h
    self.class.daily_blanks_from(tutorials.merge(groups) { |_k, v1, v2| v1.to_a + v2.to_a })
  end

  # validate
  def verify_daily_occupation_limit
    daily_occupations_invalid = term_group.timetables.reduce(false) do |timetable|
      accu || daily_occupations(term_student_id, timetable) > term_student.optimization_rule.occupation_limit
    end

    if contract_creation? && daily_occupations_invalid
      errors[:base] << '生徒の合計コマの上限を超えています'
    end
  end

  def verify_daily_blank_limit
    daily_blanks_invalid = term_group.timetables.reduce(false) do |timetable|
      accu || daily_blanks(term_student_id, timetable) > term_student.optimization_rule.blank_limit
    end

    if daily_blanks_invalid
      errors[:base] << '生徒の空きコマの上限を超えています'
    end
  end
end
