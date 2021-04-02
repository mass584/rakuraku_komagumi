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
  validate :verify_student_vacancy,
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

  before_validation :fetch_seat_in_database, on: :update
  before_validation :fetch_new_tutorial_pieces_group_by_student_and_timetable, on: :update
  before_validation :fetch_group_contracts_group_by_timetable, on: :update
  before_update :set_term_teacher_on_seat,
                if: :will_save_change_to_seat_id?
  before_update :unset_term_teacher_on_seat,
                if: :will_save_change_to_seat_id?
  after_update :save_seat
  after_update :save_seat_in_database

  scope :filter_by_placed, -> { where.not(seat_id: nil) }
  scope :filter_by_unplaced, -> { where(seat_id: nil) }
  scope :filter_by_student, lambda { |term_student_id|
    itself
      .joins(:tutorial_contract)
      .where('tutorial_contracts.term_student_id': term_student_id)
  }

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
    if (seat_creation? || seat_updation?) && seat.tutorial_pieces.count >= seat.position_count
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

  def verify_student_vacancy
    if (seat_creation? || seat_updation?) &&
       !seat.timetable.student_vacancies.find_by(term_student_id: tutorial_contract.term_student_id).is_vacant
      errors[:base] << '生徒の予定が空いていません'
    end
  end

  def position_occupations(term_student_id, timetable)
    @new_tutorial_pieces_group_by_student_and_timetable
      .dig(term_student_id, timetable.date_index, timetable.period_index).to_a.count
  end

  def verify_doublebooking
    if seat_creation? && position_occupations(tutorial_contract.term_student_id, seat.timetable) > 1
      errors[:base] << '生徒の予定が重複しています'
    end

    if seat_updation? && position_occupations(tutorial_contract.term_student_id, seat.timetable) > 1
      errors[:base] << '生徒の予定が重複しています'
    end
  end

  def daily_occupations(term_student_id, date_index)
    tutorials = @new_tutorial_pieces_group_by_student_and_timetable
      .dig(term_student_id, date_index).to_h
    groups = @group_contracts_group_by_timetable.dig(date_index).to_h
    tutorials_and_groups = self.class.merge_tutorials_and_groups(term, tutorials, groups)
    self.class.daily_occupations_from(tutorials_and_groups)
  end

  def verify_daily_occupation_limit
    limit = tutorial_contract.term_student.optimization_rule.occupation_limit
    if seat_creation? && daily_occupations(tutorial_contract.term_student_id, seat.timetable.date_index) > limit
      errors[:base] << '生徒の１日の合計コマの上限を超えています'
    end

    if seat_updation? && daily_occupations(tutorial_contract.term_student_id, seat.timetable.date_index) > limit
      errors[:base] << '生徒の１日の合計コマの上限を超えています'
    end
  end

  def daily_blanks(term_student_id, date_index)
    tutorials = @new_tutorial_pieces_group_by_student_and_timetable.dig(term_student_id, date_index).to_h
    groups = @group_contracts_group_by_timetable.dig(date_index).to_h
    tutorials_and_groups = self.class.merge_tutorials_and_groups(term, tutorials, groups)
    self.class.daily_blanks_from(tutorials_and_groups)
  end

  def verify_daily_blank_limit
    limit = tutorial_contract.term_student.optimization_rule.blank_limit
    if seat_creation? && daily_blanks(tutorial_contract.term_student_id, seat.timetable.date_index) > limit
      errors[:base] << '生徒の１日の空きコマの上限を超えています'
    end

    if seat_updation? && (
      daily_blanks(tutorial_contract.term_student_id, seat.timetable.date_index) > limit ||
      daily_blanks(tutorial_contract.term_student_id, @seat_in_database.timetable.date_index) > limit
    )
      errors[:base] << '生徒の１日の空きコマの上限を超えています'
    end

    if seat_deletion? && daily_blanks(tutorial_contract.term_student_id, @seat_in_database.timetable.date_index) > limit
      errors[:base] << '生徒の１日の空きコマの上限を超えています'
    end
  end

  # before_validation
  def fetch_seat_in_database
    @seat_in_database = Seat.find_by(id: seat_id_in_database)
  end

  def new_tutorial_pieces
    term
      .tutorial_pieces
      .filter_by_student(tutorial_contract.term_student_id)
      .left_joins(:tutorial_contract, seat: :timetable)
      .pluck('tutorial_pieces.id', 'seat_id', 'term_student_id', 'date_index', 'period_index')
      .map do |item|
        [:id, :seat_id, :term_student_id, :date_index, :period_index].zip(item).to_h
      end
      .map do |item|
        {
          id: item[:id],
          seat_id: item[:id] == id ? seat_id : item[:seat_id],
          term_student_id: item[:term_student_id],
          date_index: item[:id] == id ? seat&.timetable&.date_index : item[:date_index],
          period_index: item[:id] == id ? seat&.timetable&.period_index : item[:period_index],
        }
      end
      .select { |item| item[:seat_id].present? }
  end

  def fetch_new_tutorial_pieces_group_by_student_and_timetable
    @new_tutorial_pieces_group_by_student_and_timetable = new_tutorial_pieces.group_by_recursive(
      proc { |item| item[:term_student_id] },
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  def fetch_group_contracts_group_by_timetable
    @group_contracts_group_by_timetable = GroupContract.group_by_timetable_for_student(term, tutorial_contract.term_student_id)
  end

  # before_update
  def set_term_teacher_on_seat
    if (seat_creation? || seat_updation?) && seat.tutorial_pieces.count == 0 
      seat.term_teacher_id = tutorial_contract.term_teacher_id
    end
  end

  def unset_term_teacher_on_seat
    if (seat_updation? || seat_deletion?) && @seat_in_database.tutorial_pieces.count == 1
      @seat_in_database.term_teacher_id = nil
    end
  end

  # after_update
  def save_seat
    raise ActiveRecord::Rollback if (seat.present? && !seat.save)
  end

  def save_seat_in_database
    raise ActiveRecord::Rollback if (@seat_in_database.present? && !@seat_in_database.save)
  end
end
