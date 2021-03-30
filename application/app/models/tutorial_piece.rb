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
  validate :verify_daily_occupation_limit,
           on: :update,
           if: :will_save_change_to_seat_id?
  validate :verify_daily_blank_limit,
           on: :update,
           if: :will_save_change_to_seat_id?
  accepts_nested_attributes_for :seat

  before_update :set_term_teacher_on_seat,
                if: :will_save_change_to_seat_id?
  before_update :unset_term_teacher_on_seat,
                if: :will_save_change_to_seat_id?

  scope :filter_by_placed, -> { where.not(seat_id: nil) }
  scope :filter_by_unplaced, -> { where(seat_id: nil) }
  scope :filter_by_student, lambda { |term_student_id|
    itself
      .joins(:tutorial_contract)
      .where('tutorial_contracts.term_student_id': term_student_id)
  }

  def self.overwrite_seat_id(id, seat_id)
    itself.map do |item|
      item.seat_id = seat_id if item.id == id
      item
    end
  end

  def self.group_by_student_and_date_and_period
    itself.group_by_recursive(
      proc { |item| item.tutorial_contract.term_student_id },
      proc { |item| item.seat.timetable.date_index },
      proc { |item| item.seat.timetable.period_index },
    )
  end

  def self.position_occupations(term_student_id, timetable)
    itself
      .group_by_student_and_date_and_period
      .dig(term_student_id, timetable.date_index, timetable.period_index)
  end

  def self.daily_occupations(term_student_id, timetable)
    tutorials = itself
      .group_by_student_and_date_and_period
      .dig(term_student_id, timetable.date_index)
    groups = timetable.term.group_contracts
      .filter_by_student(term_student_id)
      .filter_by_is_contracted
      .group_by_date_and_period
      .dig(timetable.date_index)
    self.class.daily_occupations_from(tutorials.deep_merge(groups))
  end

  def self.daily_blanks(term_student_id, timetable)
    tutorials = itself
      .group_by_student_and_date_and_period
      .dig(term_student_id, timetable.date_index)
    groups = timetable.term.group_contracts
      .filter_by_term_student_id(term_student_id)
      .filter_by_is_contracted
      .group_by_date_and_period
      .dig(timetable.date_index)
    self.class.daily_blanks_from(tutorials.deep_merge(groups))
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

  def seat_in_database
    Seat.find_by(id: seat_id_in_database) || Seat.new
  end

  def new_tutorial_pieces
    term
      .tutorial_pieces
      .filter_by_student(tutorial_contract.term_student_id)
      .overwrite_seat_id(id, seat_id)
  end

  # validate
  def verify_seat_occupation
    if (seat_creation? || seat_updation?) && seat.pieces.count >= term.position_limit
      errors[:base] << '座席の最大人数をオーバーしています'
    end
  end

  def verify_term_teacher
    if seat_creation? && tutorial_contract.term_teacher_id.nil?
      errors[:base] << '担当講師が設定されていません'
    end

    if (seat_creation? || seat_updation?) &&
      seat.term_teacher_id.present? &&
      seat.term_teacher_id != tutorial_contract.term_teacher_id
      errors[:base] << '座席に割り当てられた講師と担当講師が一致しません'
    end
  end

  def verify_doublebooking
    if seat_creation? && new_tutorial_pieces.position_occupations(tutorial_contract.term_student_id, seat.timetable) > 1
      errors[:base] << '生徒の予定が重複しています'
    end

    if seat_updation? && new_tutorial_pieces.position_occupations(tutorial_contract.term_student_id, seat.timetable) > 1
      errors[:base] << '生徒の予定が重複しています'
    end
  end

  def verify_daily_occupation_limit
    if seat_creation? && new_tutorial_pieces.daily_occupations(tutorial_contract.term_student_id, seat.timetable) > 3
      errors[:base] << '生徒の合計コマの上限（３コマ）を超えています'
    end

    if seat_updation? && new_tutorial_pieces.daily_occupations(tutorial_contract.term_student_id, seat.timetable) > 3
      errors[:base] << '生徒の合計コマの上限（３コマ）を超えています'
    end
  end

  def verify_daily_blank_limit
    if seat_creation? && new_tutorial_pieces.daily_blanks(tutorial_contract.term_student_id, seat.timetable) > 2
      errors[:base] << '生徒の空きコマの上限（２コマ）を超えています'
    end

    if seat_updation? && (
      new_tutorial_pieces.daily_blanks(tutorial_contract.term_student_id, seat.timetable) > 2 ||
      new_tutorial_pieces.daily_blanks(tutorial_contract.term_student_id, seat_in_database.timetable) > 2
    )
      errors[:base] << '生徒の空きコマの上限（２コマ）を超えています'
    end

    if seat_deletion? && new_tutorial_pieces.daily_blanks(tutorial_contract.term_student_id, seat_in_database.timetable) > 2
      errors[:base] << '生徒の空きコマの上限（２コマ）を超えています'
    end
  end

  # before_update
  def set_term_teacher_on_seat
    if (seat_creation? || seat_updation?) && new_tutorial_pieces.position_occupations(tutorial_contract.term_student_id, seat.timetable).positive?
      seat.term_teacher_id = tutorial_contract.term_teacher_id
      # TODO これをトランザクションで保存する
    end
  end

  def unset_term_teacher_on_seat
    if (seat_updation? || seat_deletion?) && new_tutorial_pieces.position_occupations(tutorial_contract.term_student_id, seat.timetable).zero?
      seat_in_database.term_teacher_id = nil
      # TODO これをトランザクションで保存する
    end
  end
end
