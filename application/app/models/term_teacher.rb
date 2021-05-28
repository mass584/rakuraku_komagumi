class TermTeacher < ApplicationRecord
  include RankedModel
  belongs_to :term
  belongs_to :teacher
  has_many :term_group_term_teachers, dependent: :destroy
  has_many :term_teachers, through: :term_group_term_teachers
  has_many :term_groups, dependent: :restrict_with_exception
  has_many :tutorial_contracts, dependent: :restrict_with_exception
  has_many :tutorial_pieces, through: :tutorial_contracts
  has_many :seats, dependent: :restrict_with_exception
  has_many :teacher_vacancies, dependent: :destroy

  enum vacancy_status: {
    draft: 0,
    submitted: 1,
    fixed: 2,
  }

  ranks :row_order

  before_create :set_nest_objects

  scope :ordered, lambda {
    joins(:teacher).order('teachers.name': 'ASC')
  }
  scope :pagenated, lambda { |page, page_size|
    page.instance_of?(Integer) && page_size.instance_of?(Integer) ?
      offset((page - 1) * page_size).limit(page_size) :
      itself
  }
  scope :named, lambda {
    joins(:teacher).select('term_teachers.*', 'teachers.name AS teacher_name')
  }

  def self.new(attributes = {})
    attributes[:vacancy_status] ||= 'draft'
    super(attributes)
  end

  def self.schedule_pdfs(term, term_teachers)
    generate_schedule_pdf(term, term_teachers)
  end

  def self.generate_schedule_pdf(term, term_teachers)
    tutorial_pieces = TutorialPiece.with_tutorial_contract.with_seat_and_timetable.where(
      'term_teachers.id': term_teachers.map(&:id),
    )
    term_groups = Timetable.with_term_group_term_teachers.where(
      term_id: term.id,
      'term_group_term_teachers.term_teacher_id': term_teachers.map(&:id),
    )
    timetables = Timetable.with_group.with_teacher_vacancies.where(
      term_id: term.id,
      'teacher_vacancies.term_teacher_id': term_teachers.map(&:id),
    )
    TeacherSchedule.new(term, term_teachers, tutorial_pieces, term_groups, timetables)
  end

  def optimization_rule
    @optimization_rule ||= term.teacher_optimization_rules.first
  end

  def unplaced_tutorial_count
    tutorial_pieces.filter_by_unplaced.count
  end

  def contracted_tutorial_count
    tutorial_contracts.sum(:piece_count)
  end

  def schedule_pdf
    self.class.generate_schedule_pdf(term, [self])
  end

  def send_schedule_notification_email
    if teacher.email.blank?
      errors.add(:base, "#{teacher.name}さん：メールアドレスが入力されていません")
    else
      TeacherMailer.schedule_notifications(term: term, teacher: teacher, pdf: schedule_pdf).deliver_now
    end
  end

  private

  # before_create
  def set_nest_objects
    self.teacher_vacancies = new_teacher_vacancies
  end

  def new_teacher_vacancies
    term.timetables.map do |timetable|
      TeacherVacancy.new({ timetable_id: timetable.id })
    end
  end
end
