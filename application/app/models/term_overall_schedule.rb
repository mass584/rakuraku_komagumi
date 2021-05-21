class TermOverallSchedule
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  extend OccupationsBlanks

  attr_accessor :term_id, :tutorial_pieces, :seats

  validate :verify_daily_blank_limit_for_teacher
  validate :verify_daily_blank_limit_for_student

  before_validation :fetch_groups_group_by_timetable

  def save
    term.transaction do
      term.tutorial_pieces.update_all(seat_id: nil, is_fixed: false)
      term.seats.update_all(term_teacher_id: nil)
      seats.each do |seat|
        record = term.seats.find_by(id: seat[:id])
        record.update(term_teacher_id: seat[:term_teacher_id])
      end
      tutorial_pieces.each do |tutorial_piece|
        record = term.tutorial_pieces.find_by(id: tutorial_piece[:id])
        record.update(
          seat_id: tutorial_piece[:seat_id],
          is_fixed: tutorial_piece[:is_fixed],
        )
      end
    end
  end

  private

  def term
    @term ||= Term.find_by(id: term_id)
    @term
  end

  # validation
  def daily_blanks_for_teacher_on_one_day(seats_in_term, term_teacher_id, date_index)
    tutorials = term.period_index_array.reduce({}) do |accu, period_index|
      seats_on_this_period = seats_in_term.filter do |seat|
        seat.date_index == date_index && seat.period_index == period_index
      end
      is_exist = seats.find do |seat|
        seat[:term_teacher_id] == term_teacher_id && seats_on_this_period.include?(seat[:id])
      end
      is_exist ? accu.merge({ date_index => is_exist }) : accu
    end
    groups = @groups_group_by_timetable[date_index].to_h
    self.class.daily_blanks_from(term, tutorials, groups)
  end

  def verify_daily_blank_limit_for_teacher
    seats_in_term = term.seats.with_index
    term_teacher_and_date = term.term_teachers.product(term.date_index_array)
    term_teacher_and_date.reduce(true) do |result, item|
      blank_limit = item[0].optimization_rule.blank_limit
      blanks = daily_blanks_for_teacher_on_one_day(seats_in_term, item[0].id, item[1])
      is_valid = blanks <= blank_limit
      result && is_valid
    end
  end

  def daily_blanks_for_student_on_one_day(seats_in_term, term_student_id, date_index)
    tutorials = term.period_index_array.reduce({}) do |accu, period_index|
      seats_on_this_period = seats_in_term.filter do |seat|
        seat.date_index == date_index && seat.period_index == period_index
      end
      is_exist = tutorial_pieces.find do |tutorial_piece|
        tutorial_piece[:term_student_id] == term_student_id &&
          seats_on_this_period.include?(tutorial_piece[:seat_id])
      end
      is_exist ? accu.merge({ date_index => is_exist }) : accu
    end
    groups = @groups_group_by_timetable[date_index].to_h
    self.class.daily_blanks_from(term, tutorials, groups)
  end

  def verify_daily_blank_limit_for_student
    seats_in_term = term.seats.with_index
    term_student_and_date = term.term_students.product(term.date_index_array)
    term_student_and_date.reduce(true) do |result, item|
      blank_limit = item[0].optimization_rule.blank_limit
      blanks = daily_blanks_for_student_on_one_day(seats_in_term, item[0].id, item[1])
      is_valid = blanks <= blank_limit
      result && is_valid
    end
  end

  # callback
  def fetch_groups_group_by_timetable
    records = term
              .group_contracts
              .filter_by_student(tutorial_contract.term_student_id)
              .filter_by_is_contracted
              .joins(term_group: :timetables)
              .select(:term_student_id, :date_index, :period_index)
    @groups_group_by_timetable = records.group_by_recursive(
      proc { |item| item[:date_index] },
      proc { |item| item[:period_index] },
    )
  end
end
