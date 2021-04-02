class TutorialContract < ApplicationRecord
  belongs_to :term
  belongs_to :term_student
  belongs_to :term_tutorial
  belongs_to :term_teacher, optional: true
  has_many :tutorial_pieces, dependent: :destroy

  validates :piece_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :verify_update_term_teacher_id,
           on: :update,
           if: :will_save_change_to_term_teacher_id?
  validate :verify_under_limit_of_piece_count,
           on: :update,
           if: :will_save_change_to_piece_count?

  before_save :nest_tutorial_pieces_creation, if: :nest_tutorial_pieces_creation?
  before_save :nest_tutorial_pieces_deletion, if: :nest_tutorial_pieces_deletion?

  scope :filter_by_student, lambda { |term_student_id|
    itself.where(term_student_id: term_student_id)
  }

  def self.new(attributes = {})
    attributes[:piece_count] ||= 0
    super(attributes)
  end

  def self.group_by_student_and_timetable(term)
    records = term
      .tutorial_contracts
      .joins(tutorial_pieces: [seat: :timetable])
      .select("tutorial_contracts.*", "timetables.*")
    records.reduce({}) do |accu, record|
      accu.deep_merge({
        record.term_student_id => {
          record.date_index => {
            record.period_index => [record]
          }
        }
      })
    end
  end

  private

  def increment_count
    piece_count - piece_count_in_database.to_i
  end

  def decrement_count
    piece_count_in_database.to_i - piece_count
  end

  # validate
  def verify_update_term_teacher_id
    if tutorial_pieces.filter_by_placed.count.positive?
      errors[:base] << '配置済みのコマがあるため担任を変更できません'
    end
  end

  def verify_under_limit_of_piece_count
    if decrement_count > tutorial_pieces.filter_by_unplaced.count
      errors[:base] << '配置済みのコマを未決定に戻す必要があります'
    end
  end

  # before_save
  def nest_tutorial_pieces_creation?
    increment_count.positive?
  end

  def nest_tutorial_pieces_creation
    tutorial_pieces.build(increment_count.times.map { { term_id: term.id } })
  end

  def nest_tutorial_pieces_deletion?
    decrement_count.positive?
  end

  def nest_tutorial_pieces_deletion
    tutorial_pieces.filter_by_unplaced.limit(decrement_count).delete_all
  end
end
