class Seat < ApplicationRecord
  belongs_to :term
  belongs_to :timetable
  belongs_to :term_teacher, optional: true
  has_many :tutorial_pieces, dependent: :destroy

  validates :seat_index,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validate :verify_doublebooking,
           on: :update,
           if: :will_save_change_to_term_teacher_id?
  validate :verify_day_occupation_limit,
           on: :update,
           if: :will_save_change_to_seat_id?
  validate :verify_day_blank_limit,
           on: :update,
           if: :will_save_change_to_seat_id?

  def self.new(attributes)
    attributes[:term_teacher_id] ||= nil
    super(attributes)
  end

  def self.record_exists?(timetable_id, term_teacher_id)
    self.class.where(timetable_id: timetable_id, term_teacher_id: term_teacher_id).exists?
  end

  private

  def term_teacher_creation?
    seat_id_in_database.nil? && seat_id.present?
  end

  def term_teacher_updation?
    seat_id_in_database.present? && seat_id.present? && seat_id_in_database != seat_id
  end

  def term_teacher_deletion?
    seat_id_in_database.present? && seat_id.nil?
  end

  # validate
  def verify_doublebooking
    if (term_teacher_creation? || term_teacher_updation?) &&
      self.class.record_exists?(timetable_id, term_teacher_id)
      errors[:base] << '講師の予定が重複しています'
    end
  end

  def verify_day_occupation_limit
    if (seat_creation? || seat_updation?)
      errors[:base] << '合計コマの上限を超えています'
    end
  end

  def verify_day_blank_limit
    if (seat_creation? || seat_updation?)
      errors[:base] << '空きコマの上限を超えています'
    end
  end
end
