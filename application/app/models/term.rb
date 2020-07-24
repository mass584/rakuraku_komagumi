class Term < ApplicationRecord
  belongs_to :room
  has_many :student_terms, dependent: :destroy
  has_many :students, through: :student_terms
  has_many :teacher_terms, dependent: :destroy
  has_many :teachers, through: :teacher_terms
  has_many :subject_terms, dependent: :destroy
  has_many :subjects, through: :subject_terms
  has_many :begin_end_times, dependent: :destroy
  has_many :timetables, dependent: :destroy
  has_many :contracts, dependent: :destroy
  has_many :student_requests, dependent: :destroy
  has_many :teacher_requests, dependent: :destroy
  has_many :seats, dependent: :destroy
  has_many :pieces, dependent: :destroy

  validate :verify_context
  enum type: { one_week: 0, variable: 1 }

  after_create :create_associations

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

  def frame_array
    (1..max_frame)
  end

  def pieces_for_student(student_term_id)
    @pieces_for_student ||= pieces_per_timetable(
      pieces.where(student_term_id: student_term_id),
    )
  end

  def pieces_for_teacher(teacher_term_id)
    @pieces_for_teacher ||= pieces_per_timetable(
      pieces.where(teacher_term_id: teacher_term_id),
    )
  end

  def all_pieces
    @all_pieces ||= pieces_per_timetable(pieces)
  end

  def pending_pieces
    @pending_pieces ||= pieces.joins(:student, :subject, :teacher).select(
      "pieces.id AS id, student_id, students.name AS student_name, subject_id, subjects.name AS subject_name, teacher_id, teachers.name AS teacher_name, status"
    ).where(timetable_id: nil).group_by_recursive(
      proc { |item| item.student_id },
      proc { |item| item.subject_id },
    )
  end

  def ordered_students
    student_terms.joins(:student).order(birth_year: 'ASC')
  end

  def ordered_teachers
    teacher_terms.joins(:teacher).order(name: 'DESC')
  end

  def ordered_subjects
    subject_terms.joins(:subject).order(order: 'ASC')
  end

  def readied_students
    students.joins(:student_terms).where('student_terms.is_decided': true)
  end

  def readied_teachers
    teachers.joins(:teacher_terms).where('teacher_terms.is_decided': true)
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
    Seat.bulk_create(self)
  end

  def pieces_per_timetable(items)
    items.where.not(timetable_id: nil).group_by_recursive(
      proc { |item| item.timetable.date },
      proc { |item| item.timetable.period },
    )
  end
end
