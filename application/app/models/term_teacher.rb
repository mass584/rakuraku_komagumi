class TermTeacher < ApplicationRecord
  belongs_to :term
  belongs_to :teacher
  has_many :term_groups, dependent: :restrict_with_exception
  has_many :tutorial_contracts, dependent: :restrict_with_exception
  has_many :seats, dependent: :restrict_with_exception 
  has_many :teacher_vacancies, dependent: :destroy

  enum vacancy_status: {
    draft: 0,
    submitted: 1,
    fixed: 2,
  }

  before_create :set_nest_objects

  scope :ordered, lambda {
    joins(:teacher).order('teachers.name': 'ASC')
  }
  scope :pagenated, lambda { |page, page_size|
    page.instance_of?(Integer) && page_size.instance_of?(Integer) ?
      slice((page - 1) * page_size, page_size) :
      itself
  }

  def self.new(attributes = {})
    attributes[:vacancy_status] ||= 'draft'
    super(attributes)
  end

  def optimization_rule
    @optimization_rule ||= term.teacher_optimization_rules.first
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
