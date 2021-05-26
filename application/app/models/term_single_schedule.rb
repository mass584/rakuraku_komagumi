class TermSingleSchedule
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  extend OccupationsBlanks

  attr_accessor :tutorial_piece_id, :seat_id

  validate :verify_teacher_daily_blank_limit
  validate :verify_student_daily_blank_limit

  before_validation :fetch_tutorials_group_by_teacher_and_timetable
  before_validation :fetch_groups_group_by_teacher_and_timetable
  before_validation :fetch_tutorials_group_by_student_and_timetable
  before_validation :fetch_groups_group_by_student_and_timetable

  def save
    return false if !valid?

    if creation?
      creation_transaction
    elsif updation?
      updation_transaction
    elsif deletion?
      deletion_transaction
    else
      true
    end
  end

  private

  def tutorial_piece
    @tutorial_piece ||= TutorialPiece.find_by(id: tutorial_piece_id)
    @tutorial_piece
  end

  def term
    @term ||= Term.find_by(id: tutorial_piece.term_id)
    @term
  end

  def before_seat
    @before_seat ||= tutorial_piece.seat
    @before_seat
  end

  def after_seat
    @after_seat ||= Seat.find_by(id: seat_id)
    @after_seat
  end

  def term_teacher
    @term_teacher ||= TermTeacher.find_by(
      id: tutorial_piece.tutorial_contract.term_teacher_id,
    )
    @term_teacher
  end

  def term_student
    @term_student ||= TermStudent.find_by(
      id: tutorial_piece.tutorial_contract.term_student_id,
    )
    @term_student
  end

  def empty_before_seat?
    before_seat.tutorial_pieces.count == 1
  end

  def creation?
    before_seat.nil? && after_seat.present?
  end

  def updation?
    before_seat.present? && after_seat.present? && before_seat.id != after_seat.id
  end

  def deletion?
    before_seat.present? && after_seat.nil?
  end

  def creation_transaction
    ActiveRecord::Base.transaction do
      after_seat.update(term_teacher_id: term_teacher.id)
      tutorial_piece.update(seat_id: after_seat.id)
    end
  end

  def updation_transaction
    ActiveRecord::Base.transaction do
      if empty_before_seat?
        before_seat.update(term_teacher_id: nil)
      end
      after_seat.update(term_teacher_id: term_teacher.id)
      tutorial_piece.update(seat_id: after_seat.id)
    end
  end

  def deletion_transaction
    ActiveRecord::Base.transaction do
      if empty_before_seat?
        before_seat.update(term_teacher_id: nil)
      end
      tutorial_piece.update(seat_id: nil)
    end
  end

  # validation
  def daily_blanks_for_teacher_on_before_seat
    date_index = before_seat.timetable.date_index
    period_index = before_seat.timetable.period_index
    tutorials = @tutorials_group_by_teacher_and_timetable
                .dig(term_teacher.id, date_index).to_h
    tutorials.delete(period_index) if empty_before_seat?
    if after_seat.present? && date_index == after_seat.timetable.date_index
      tutorials.merge!({ after_seat.timetable.period_index => [tutorial_piece] })
    end
    groups = @groups_group_by_teacher_and_timetable
             .dig(term_teacher.id, date_index).to_h
    self.class.daily_blanks_from(term, tutorials, groups)
  end

  def daily_blanks_for_teacher_on_after_seat
    date_index = after_seat.timetable.date_index
    period_index = after_seat.timetable.period_index
    tutorials = @tutorials_group_by_teacher_and_timetable
                .dig(term_teacher.id, date_index).to_h
    tutorials.merge!({ period_index => [tutorial_piece] })
    if before_seat.present? && date_index == before_seat.timetable.date_index && empty_before_seat?
      tutorials.delete(before_seat.timetable.period_index)
    end
    groups = @groups_group_by_teacher_and_timetable
             .dig(term_teacher.id, date_index).to_h
    self.class.daily_blanks_from(term, tutorials, groups)
  end

  def daily_blanks_for_student_on_before_seat
    date_index = before_seat.timetable.date_index
    period_index = before_seat.timetable.period_index
    tutorials = @tutorials_group_by_student_and_timetable
                .dig(term_student.id, date_index).to_h
    tutorials.delete(period_index)
    if after_seat.present? && date_index == after_seat.timetable.date_index
      tutorials.merge!({ after_seat.timetable.period_index => [tutorial_piece] })
    end
    groups = @groups_group_by_student_and_timetable
             .dig(term_student.id, date_index).to_h
    self.class.daily_blanks_from(term, tutorials, groups)
  end

  def daily_blanks_for_student_on_after_seat
    date_index = after_seat.timetable.date_index
    period_index = after_seat.timetable.period_index
    tutorials = @tutorials_group_by_student_and_timetable
                .dig(term_student.id, date_index).to_h
    tutorials.merge!({ period_index => [tutorial_piece] })
    if before_seat.present? && date_index == before_seat.timetable.date_index
      tutorials.delete(before_seat.timetable.period_index)
    end
    groups = @groups_group_by_student_and_timetable
             .dig(term_student.id, date_index).to_h
    self.class.daily_blanks_from(term, tutorials, groups)
  end

  def verify_teacher_daily_blank_limit
    if (creation? || updation?) &&
       daily_blanks_for_teacher_on_after_seat > term_teacher.optimization_rule.blank_limit
      errors.add(:base, '講師の１日の空きコマの上限を超えています')
    end

    if (updation? || deletion?) &&
       daily_blanks_for_teacher_on_before_seat > term_teacher.optimization_rule.blank_limit
      errors.add(:base, '講師の１日の空きコマの上限を超えています')
    end
  end

  def verify_student_daily_blank_limit
    if (creation? || updation?) &&
       daily_blanks_for_student_on_after_seat > term_teacher.optimization_rule.blank_limit
      errors.add(:base, '生徒の１日の空きコマの上限を超えています')
    end

    if (updation? || deletion?) &&
       daily_blanks_for_student_on_before_seat > term_teacher.optimization_rule.blank_limit
      errors.add(:base, '生徒の１日の空きコマの上限を超えています')
    end
  end

  # callback
  def fetch_tutorials_group_by_teacher_and_timetable
    records = term.seats.joins(:timetable)
                  .select(:id, :term_teacher_id, :date_index, :period_index)
                  .select { |item| item[:term_teacher_id].present? }
    @tutorials_group_by_teacher_and_timetable = records.group_by_recursive(
      proc { |item| item[:term_teacher_id] },
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  def fetch_groups_group_by_teacher_and_timetable
    records = term.timetables.joins(term_group: :term_group_term_teachers)
                  .select(:term_teacher_id, :date_index, :period_index)
                  .select { |item| item[:term_teacher_id].present? }
    @groups_group_by_teacher_and_timetable = records.group_by_recursive(
      proc { |item| item[:term_teacher_id] },
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  def fetch_tutorials_group_by_student_and_timetable
    records = term.tutorial_pieces.joins(:tutorial_contract, seat: :timetable)
                  .select(:term_student_id, :date_index, :period_index)
    @tutorials_group_by_student_and_timetable = records.group_by_recursive(
      proc { |item| item[:term_student_id] },
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end

  def fetch_groups_group_by_student_and_timetable
    records = term.group_contracts.filter_by_is_contracted
                  .joins(term_group: :timetables)
                  .select(:term_student_id, :date_index, :period_index)
    @groups_group_by_student_and_timetable = records.group_by_recursive(
      proc { |item| item[:term_student_id] },
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end
end
