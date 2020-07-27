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

  before_save :update_new_seat,
              on: :update,
              if: :will_save_change_to_seat_id?
  after_save :update_old_seat,
             on: :update,
             if: :saved_change_to_seat_id?

  def update(params)
    if params[:seat_id].present?
      super(params.merge({ seat_id: nil }))
      super({ seat_id: params[:seat_id] })
    end
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

  def update_new_seat
    if seat.present?
      seat.update(teacher_term_id: contract.teacher_term_id)
    end
  end

  def update_old_seat
    seat_before_last_save = Seat.find_by(id: seat_id_before_last_save)
    if seat_before_last_save.present? && seat_before_last_save.pieces.empty?
      seat_before_last_save.update(teacher_term_id: nil)
    end
  end
end
