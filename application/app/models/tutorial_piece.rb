class TutorialPiece < ApplicationRecord
  belongs_to :term
  belongs_to :tutorial_contract
  belongs_to :seat, optional: true

  validate :verify_seat_occupation,
           on: :update,
           if: :will_save_change_to_seat_id?
  validate :verify_term_teacher,
           on: :update,
           if: :will_save_change_to_seat_id?
  validate :verify_doublebooking,
           on: :update,
           if: :will_save_change_to_seat_id?
  validate :verify_day_occupation_limit,
           on: :update,
           if: :will_save_change_to_seat_id?
  validate :verify_day_blank_limit,
           on: :update,
           if: :will_save_change_to_seat_id?
  accepts_nested_attributes_for :seat

  before_update :set_term_teacher_on_seat,
                if: :will_save_change_to_seat_id?
  before_update :unset_term_teacher_on_seat,
                if: :will_save_change_to_seat_id?

  def self.record_exists?(timetable_id, term_student_id)
    self.class.joins([:tutorial_contract, :seat]).where(
      'tutorial_contracts.term_student_id': term_student_id,
      'seats.timetable_id': timetable_id,
    ).exists?
  end

  private

  def seat_creation?
    seat_id_in_database.nil? && seat_id.present?
  end

  def seat_updation?
    seat_id_in_database.present? && seat_id.present? && seat_id_in_database != seat_id
  end

  def seat_deletion?
    seat_id_in_database.present? && seat_id.nil?
  end

  # validate
  def verify_seat_occupation
    if (seat_creation? || seat_updation?) &&
      seat.pieces.count >= term.positions
      errors[:base] << '座席の最大人数をオーバーしています'
    end
  end

  def verify_term_teacher
    if (seat_creation? || seat_updation?) &&
      seat.term_teacher_id.present? &&
      seat.term_teacher_id != tutorial_contract.term_teacher_id
      errors[:base] << '座席に割り当てられた講師と担当講師が一致しません'
    end
  end

  def verify_doublebooking
    if (seat_creation? || seat_updation?) &&
      self.class.record_exists?(seat.timetable_id, tutorial_contract.term_student_id)
      errors[:base] << '生徒の予定が重複しています'
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

  # before_callback
  def set_term_teacher_on_seat
    if (seat_creation? || seat_updation?) && seat.pieces.count.zero?
      seat.term_teacher_id = tutorial_contract.term_teacher_id
    end
  end

  def unset_term_teacher_on_seat
    if (seat_updation? || seat_deletion?) && seat_in_database.pieces.count == 1
      seat_in_database.term_teacher_id = nil
    end
  end
end
