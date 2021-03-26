class TermTeacher < ApplicationRecord
  belongs_to :term
  belongs_to :teacher
  has_many :term_groups, dependent: :restrict_with_exception
  has_many :tutorial_contracts, dependent: :restrict_with_exception
  has_many :seats, dependent: :restrict_with_exception 
  has_many :teacher_vacancies, dependent: :destroy
  accepts_nested_attributes_for :teacher_vacancies

  enum vacancy_status: {
    draft: 0,
    submitted: 1,
    fixed: 2,
  }

  def self.new(attributes)
    attributes[:teacher_vacancies] ||= new_teacher_vacancies
    super(attributes)
  end

  private

  def new_teacher_vacancies
    term.timetables.map { |timetable| { timetable_id: timetable.id } }
  end
end
