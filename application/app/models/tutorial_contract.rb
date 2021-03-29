class TutorialContract < ApplicationRecord
  belongs_to :term
  belongs_to :term_student
  belongs_to :term_tutorial
  belongs_to :term_teacher, optional: true
  has_many :tutorial_pieces, dependent: :destroy
  accepts_nested_attributes_for :tutorial_pieces, allow_destroy: true

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

  def self.new(attributes = {})
    attributes[:piece_count] ||= 0
    super(attributes)
  end

  private

  def placed_tutorial_pieces
    tutorial_pieces.where.not(seat_id: nil).count
  end

  def unplaced_tutorial_pieces
    tutorial_pieces.where(seat_id: nil).count
  end

  def increment_count
    piece_count - piece_count_in_database.to_i
  end

  def decrement_count
    piece_count_in_database.to_i - piece_count
  end

  # validate
  def verify_update_term_teacher_id
    unless placed_tutorial_pieces.positive?
      errors[:base] << '配置済みのコマがあるため担任を変更できません'
    end
  end

  def verify_under_limit_of_piece_count
    unless decrement_count <= unplaced_tutorial_pieces
      errors[:base] << '配置済みのコマを未決定に戻す必要があります'
    end
  end

  # callback
  def nest_tutorial_pieces_creation?
    increment_count.positive?
  end

  def nest_tutorial_pieces_creation
    tutorial_pieces(increment_count.times.map { { term_id: term.id } })
  end

  def nest_tutorial_pieces_deletion?
    decrement_count.positive?
  end

  def nest_tutorial_pieces_deletion
    tutorial_pieces(decrement_count.times.map { { seat_id: nil, _destroy: true } })
  end
end
