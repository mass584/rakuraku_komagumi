class Piece < ApplicationRecord
  belongs_to :term
  belongs_to :contract
  belongs_to :seat, optional: true

  validate :verify_seat_occupation,
           on: :update,
           if: :will_save_change_to_seat_id?
  validate :verify_tannin,
           on: :update,
           if: :will_save_change_to_seat_id?
  validate :verify_doublebooking,
           on: :update,
           if: :will_save_change_to_seat_id?

  def self.pieces_for_student(term, student_term)
    pieces_per_timetable(
      term.pieces.includes(:contract).where(
        'contracts.student_term_id': student_term.id,
      ),
    )
  end

  def self.pieces_for_teacher(term, teacher_term)
    pieces_per_timetable(
      term.pieces.includes(:seat).where(
        'seats.teacher_term_id': teacher_term.id,
      ),
    )
  end

  def self.pieces(term)
    pieces_per_timetable(
      term.pieces.includes(
        timetable: [],
        contracts: [
          student_term: [:student],
          subject_term: [:subject]
        ],
      ).where.not(seat_id: nil),
    )
  end

  private

  def verify_seat_occupation
    if seat_id.present? &&
       Piece.where(seat_id: seat_id).count >= term.max_frame
      errors[:base] << '座席の最大人数をオーバーしています'
    end
  end

  def verify_tannin
    if seat_id.present? &&
       seat.teacher_term_id.present? &&
       seat.teacher_term_id != contract.teacher_term_id
      errors[:base] << '座席の講師と担当の講師が一致しません'
    end
  end

  def verify_doublebooking
    if seat_id.present? &&
       Piece.joins(:contract, :seat).where(
         'contracts.student_term_id': contract.student_term_id,
         'seats.timetable_id': seat.timetable_id,
       ).where.not(seat_id: seat_id_in_database).count >= 1
      errors[:base] << '生徒のダブルブッキングがあります'
    end
  end

  def pieces_per_timetable(pieces)
    pieces.where.not(seat_id: nil).group_by_recursive(
      proc { |item| item.seat.timetable.date },
      proc { |item| item.seat.timetable.period },
    )
  end
end
