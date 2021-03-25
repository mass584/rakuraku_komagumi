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
  enum type: { normal: 0, season: 1 }

  def dates
    if normal?
      7
    elsif season?
      (begin_at..end_at).to_a.length
    end
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
    return min_week if week < min_week
    return max_week if week > max_week
    week
  end

  def min_week
    1
  end

  def max_week
    (1 + (end_at - begin_at) / 7).to_i
  end

  private

  def valid_context?
    if (end_at - begin_at).negative?
      errors[:base] << '開始日・終了日を正しく設定してください'
    end
  end
end
