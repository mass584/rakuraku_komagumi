class Piece < ApplicationRecord
  belongs_to :term
  belongs_to :contract
  belongs_to :seat, optional: true
  validate :verify_teacher_occupation, on: :update, if: :will_save_change_to_seat_id?
  validate :verify_student_occupation, on: :update, if: :will_save_change_to_seat_id?

  private

  def verify_tannin
    if contract.teacher_term_id != seat.teacher_term_id
      errors[:base] << '座席の講師と担当の講師が一致しません'
    end
  end

  def verify_teacher_occupation
    teacher_occupation_count = where(seat_id: seat_id).count
    if teacher_occupation_count >= term.max_piece
      errors[:base] << '講師のオーバーブッキングがあります'
    end
  end

  def verify_student_occupation
    student_occupation_count = join(:contract, :seat).where(
      'contracts.student_term_id': contract.student_term_id,
      'seats.timetable_id': seat.timetable_id,
    )
    if student_occupation_count >= 1
      errors[:base] << '生徒のダブルブッキングがあります'
    end
  end
end
