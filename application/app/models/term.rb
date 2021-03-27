class Term < ApplicationRecord
  belongs_to :room
  has_many :term_students, dependent: :destroy
  has_many :term_teachers, dependent: :destroy
  has_many :term_tutorials, dependent: :destroy
  has_many :term_groups, dependent: :destroy
  has_many :begin_end_times, dependent: :destroy
  has_many :timetables, dependent: :destroy
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
  validates :periods,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :seats,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :positions,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validate :valid_context?
  enum term_type: { normal: 0, season: 1, exam_planning: 2 }

  before_create :set_nest_objects

  def pieces_for_student(student_id)
    pieces_per_timetable(
      undetermined_tutorial_pieces.includes([
        :tutorial_contract,
        { seat: [:timetable] },
      ]).where(
        'tutorial_contracts.term_student_id': student_id,
      ),
    )
  end

  def pieces_for_teacher(teacher_id)
    pieces_per_timetable(
      undetermined_tutorial_pieces.includes([
        { seat: [:timetable] },
      ]).where(
        'seats.term_teacher_id': teacher_id,
      ),
    )
  end

  def dates
    return 7 if normal?
    return (begin_at..end_at).to_a.length if season? || exam_planning?
  end

  def date_index_array
    (1..dates).to_a
  end

  def period_index_array
    (1..periods).to_a
  end

  def seat_index_array
    (1..seats).to_a
  end

  def position_index_array
    (1..positions).to_a
  end

  def cutoff_week(week)
    return 1 if week < 1
    return max_week if week > max_week
    week
  end

  def max_week
    (1 + (end_at - begin_at) / 7).to_i
  end

  private

  def new_begin_end_times
    period_index_array.map do |index|
      BeginEndTime.new({ period_index: index, begin_at: "18:00:00", end_at: "19:10:00" })
    end
  end

  def new_timetables
    date_index_array.product(period_index_array).map do |date_index, period_index|
      Timetable.new({ date_index: date_index, period_index: period_index })
    end
  end

  def undetermined_tutorial_pieces
    tutorial_pieces.where.not(seat_id: nil)
  end

  def pieces_per_timetable(items)
    items.group_by_recursive(
      proc { |item| item.seat.timetable.date_index },
      proc { |item| item.seat.timetable.period_index },
    )
  end

  def pieces_per_seat(items)
    items.group_by_recursive(
      proc { |item| item.seat.timetable.date_index },
      proc { |item| item.seat.timetable.period_index },
      proc { |item| item.seat.seat_index },
    )
  end

  # validate
  def valid_context?
    if (end_at - begin_at).negative?
      errors[:base] << '開始日・終了日を正しく設定してください'
    end
  end

  # callback
  def set_nest_objects
    self.begin_end_times = new_begin_end_times
    self.timetables = new_timetables
  end
end
