class Term < ApplicationRecord
  belongs_to :room
  has_many :student_optimization_rules, dependent: :destroy
  has_many :teacher_optimization_rules, dependent: :destroy
  has_many :term_students, dependent: :destroy
  has_many :term_teachers, dependent: :destroy
  has_many :term_tutorials, dependent: :destroy
  has_many :term_groups, dependent: :destroy
  has_many :begin_end_times, dependent: :destroy
  has_many :timetables, -> { ordered }, dependent: :destroy
  has_many :seats, dependent: :destroy
  has_many :tutorial_contracts, dependent: :destroy
  has_many :group_contracts, dependent: :destroy
  has_many :tutorial_pieces, dependent: :destroy

  validates :name,
            length: { minimum: 1, maximum: 40 }
  validates :term_type,
            presence: true
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

  validate :valid_context?, on: :create
  validate :valid_date_count?, on: :create

  before_create :set_nest_objects

  enum term_type: { normal: 0, season: 1, exam_planning: 2 }

  scope :cache_child_models, lambda {
    preload(term_teachers: :teacher)
      .preload(timetables: [
        { term_group: [:group, :group_contracts] },
        { seats: { tutorial_pieces: :tutorial_contract } },
        :teacher_vacancies,
        :student_vacancies,
      ])
      .preload(tutorial_pieces: [
        {
          tutorial_contract: [
            { term_tutorial: :tutorial },
            { term_student: :student },
          ],
        },
      ])
  }

  def date_count
    if normal?
      7
    elsif season?
      (begin_at..end_at).to_a.length
    elsif exam_planning?
      (begin_at..end_at).to_a.length
    end
  end

  def display_date(date_index)
    if normal?
      %w[月曜日 火曜日 水曜日 木曜日 金曜日 土曜日 日曜日][date_index - 1]
    elsif season?
      I18n.l (begin_at..end_at).to_a[date_index - 1]
    elsif exam_planning?
      I18n.l (begin_at..end_at).to_a[date_index - 1]
    end
  end

  def date_index_array(*argv)
    week = argv.first
    if week.nil?
      (1..date_count).to_a
    else
      (1..date_count).to_a.slice(week * 7 - 7, 7)
    end
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

  def max_week
    (1 + (end_at - begin_at) / 7).to_i
  end

  # validate
  def valid_context?
    if begin_at.present? && end_at.present? && (end_at - begin_at).negative?
      errors.add(:base, '開始日・終了日を正しく設定してください')
    end
  end

  def valid_date_count?
    if begin_at.present? && end_at.present? && (date_count > 50)
      errors.add(:base, '講習期とテスト対策の期間は最大５０日までです')
    end
  end

  # callback
  def set_nest_objects
    student_optimization_rules.build(new_student_optimization_rules)
    teacher_optimization_rules.build(new_teacher_optimization_rules)
    begin_end_times.build(new_begin_end_times)
    timetables.build(new_timetables)
    term_tutorials.build(new_term_tutorials)
    term_groups.build(new_term_groups)
  end

  def new_term_tutorials
    room.tutorials.active.select(:id).map do |tutorial|
      { tutorial_id: tutorial.id }
    end
  end

  def new_term_groups
    room.groups.active.select(:id).map do |group|
      { group_id: group.id }
    end
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
