class TermStudent < ApplicationRecord
  belongs_to :term
  belongs_to :student
  has_many :tutorial_contracts, dependent: :destroy
  has_many :tutorial_pieces, through: :tutorial_contracts
  has_many :group_contracts, dependent: :destroy
  has_many :student_vacancies, dependent: :destroy
  has_many :term_student_notifications, dependent: :destroy

  enum vacancy_status: {
    draft: 0,
    submitted: 1,
    fixed: 2,
  }
  enum school_grade: {
    e1: 11,
    e2: 12,
    e3: 13,
    e4: 14,
    e5: 15,
    e6: 16,
    j1: 21,
    j2: 22,
    j3: 23,
    h1: 31,
    h2: 32,
    h3: 33,
    other: 99,
  }

  before_create :set_nest_objects

  scope :ordered, lambda {
    joins(:student).order(school_grade: 'ASC', 'students.name': 'ASC')
  }
  scope :pagenated, lambda { |page, page_size|
    page.instance_of?(Integer) && page_size.instance_of?(Integer) ?
      offset((page - 1) * page_size).limit(page_size) :
      itself
  }
  scope :named, lambda {
    joins(:student).select('term_students.*', 'students.name AS student_name')
  }

  def self.new(attributes = {})
    attributes[:vacancy_status] ||= 'draft'
    record = super(attributes)
    record.school_grade = record.student&.school_grade
    record
  end

  def self.schedule_pdfs(term, term_students)
    generate_schedule_pdf(term, term_students)
  end

  def self.generate_schedule_pdf(term, term_students)
    tutorial_pieces = term.tutorial_pieces.with_tutorial_contract.with_seat_and_timetable.where(
      'term_students.id': term_students.map(&:id),
    )
    term_groups = term.timetables.with_group_contracts.where(
      'group_contracts.term_student_id': term_students.map(&:id),
      'group_contracts.is_contracted': true,
    )
    timetables = term.timetables.with_group.with_student_vacancies.where(
      'student_vacancies.term_student_id': term_students.map(&:id),
    )
    StudentSchedule.new(term, term_students, tutorial_pieces, term_groups, timetables).render
  end

  def optimization_rule
    @optimization_rule ||= term.student_optimization_rules.find_by(school_grade: school_grade)
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
    term_student_notifications.create(term: term)
  end

  private

  # before_create
  def set_nest_objects
    tutorial_contracts.build(new_tutorial_contracts)
    group_contracts.build(new_group_contracts)
    student_vacancies.build(new_student_vacancies)
  end

  def new_tutorial_contracts
    term.term_tutorials.map do |term_tutorial|
      { term_id: term.id, term_tutorial_id: term_tutorial.id }
    end
  end

  def new_group_contracts
    term.term_groups.map do |term_group|
      { term_id: term.id, term_group_id: term_group.id }
    end
  end

  def new_student_vacancies
    term.timetables.map do |timetable|
      { timetable_id: timetable.id }
    end
  end
end
