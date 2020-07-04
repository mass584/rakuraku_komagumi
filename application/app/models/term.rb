class Term < ApplicationRecord
  belongs_to :room
  has_many :begin_end_times, dependent: :destroy
  has_many :contracts, dependent: :destroy
  has_many :student_terms, dependent: :destroy
  has_many :students, through: :student_terms
  has_many :student_requests, dependent: :destroy
  has_many :subject_terms, dependent: :destroy
  has_many :subjects, through: :subject_terms
  has_many :pieces, dependent: :destroy
  has_many :teacher_terms, dependent: :destroy
  has_many :teachers, through: :teacher_terms
  has_many :teacher_requests, dependent: :destroy
  has_many :timetables, dependent: :destroy
  validate :verify_context
  after_create :create_associations
  enum type: { one_week: 0, variable: 1 }
  self.inheritance_column = :_type_disabled

  def date_array
    if one_week?
      (('2001-01-01'.to_date)..('2001-01-07'.to_date))
    elsif variable?
      (begin_at..end_at)
    end
  end

  def period_array
    (1..max_period)
  end

  def seat_array
    (1..max_seat)
  end

  def piece_array
    (1..max_piece)
  end

  def max_week
    (end_at - begin_at + 7).to_i / 7
  end

  def date_array_one_week(week_number)
    if one_week?
      ('2001-01-01'.to_date)..('2001-01-07'.to_date)
    elsif variable?
      week_number = 1 if week_number < 1
      week_number = max_week if week_number > max_week
      begindate = begin_at + (7 * week_number) - 7
      enddate = begin_at + (7 * week_number) - 1
      enddate = end_at if enddate > end_at
      begindate..enddate
    end
  end

  def readied_teachers
    teachers.joins(:teacher_terms).where('teacher_terms.status': 1)
  end

  def readied_students
    students.joins(:student_terms).where('student_terms.status': 1)
  end

  def show_type
    if one_week?
      '１週間モード'
    elsif variable?
      '任意期間モード'
    end
  end

  def ordered_students
    students.order(birth_year: 'ASC')
  end

  def ordered_teachers
    teachers.order(name: 'DESC')
  end

  def ordered_subjects
    subjects.order(order: 'ASC')
  end

  private

  def verify_context
    return if begin_at.nil? || end_at.nil?

    if variable? && (end_at - begin_at).negative?
      errors[:base] << '開始日、終了日を正しく設定してください。'
    elsif variable? && (end_at - begin_at) >= 50
      errors[:base] << '期間は50日以内に設定してください。'
    end
  end

  def create_associations
    SubjectTerm.bulk_create(self)
    StudentTerm.bulk_create(self)
    TeacherTerm.bulk_create(self)
    BeginEndTime.bulk_create(self)
    Timetable.bulk_create(self)
    Contract.bulk_create(self)
  end
end
