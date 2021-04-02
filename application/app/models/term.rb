class Term < ApplicationRecord
  belongs_to :room
  has_many :student_optimization_rules, dependent: :destroy
  has_many :teacher_optimization_rules, dependent: :destroy
  has_many :term_students, dependent: :destroy
  has_many :term_teachers, dependent: :destroy
  has_many :term_tutorials, dependent: :destroy
  has_many :term_groups, dependent: :destroy
  has_many :begin_end_times, dependent: :destroy
  has_many :timetables, dependent: :destroy
  has_many :seats, dependent: :destroy
  has_many :tutorial_contracts, dependent: :destroy
  has_many :group_contracts, dependent: :destroy
  has_many :tutorial_pieces, dependent: :destroy
  accepts_nested_attributes_for :term_tutorials, :term_groups

  validates :name,
            length: { minimum: 1, maximum: 40 }
  validates :year,
            numericality: { only_integer: true, greater_than_or_equal_to: 2020 }
  validates :begin_at, presence: true
  validates :end_at, presence: true
  validates :period_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :seat_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :position_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validate :valid_context?
  enum term_type: { normal: 0, season: 1, exam_planning: 2 }

  before_create :set_nest_objects

  def date_count
    return 7 if normal?
    return (begin_at..end_at).to_a.length if season? || exam_planning?
  end

  def date_index_array
    (1..date_count).to_a
  end

  def period_index_array
    (1..period_count).to_a
  end

  def seat_index_array
    (1..seat_count).to_a
  end

  def position_index_array
    (1..position_count).to_a
  end

  private

  def cutoff_week(week)
    return 1 if week < 1
    return max_week if week > max_week
    week
  end

  def max_week
    (1 + (end_at - begin_at) / 7).to_i
  end

  # validate
  def valid_context?
    if (end_at - begin_at).negative?
      errors[:base] << '開始日・終了日を正しく設定してください'
    end
  end

  # callback
  def set_nest_objects
    self.student_optimization_rules.build(new_student_optimization_rules)
    self.teacher_optimization_rules.build(new_teacher_optimization_rules)
    self.begin_end_times.build(new_begin_end_times)
    self.timetables.build(new_timetables)
  end

  def new_student_optimization_rules
    Student.school_grades.values.map do |school_grade|
      {
        school_grade: school_grade,
        occupation_limit: 3,
        occupation_costs: [0, 0, 14, 70],
        blank_limit: 1,
        blank_costs: [0, 70],
        interval_cutoff: 2,
        interval_costs: [70, 35, 14],
      }
    end
  end

  def new_teacher_optimization_rules
    [
      {
        single_cost: 100,
        different_pair_cost: 15,
        occupation_limit: 6,
        occupation_costs: [0, 30, 18, 3, 0, 6, 24],
        blank_limit: 1,
        blank_costs: [0, 30],
      }
    ]
  end

  def new_begin_end_times
    period_index_array.map do |index|
      { period_index: index, begin_at: "18:00:00", end_at: "19:10:00" }
    end
  end

  def new_timetables
    date_index_array.product(period_index_array).map do |date_index, period_index|
      { date_index: date_index, period_index: period_index }
    end
  end
end
