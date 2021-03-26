class TermStudent < ApplicationRecord
  belongs_to :term
  belongs_to :student
  has_many :tutorial_contracts, dependent: :destroy
  has_many :group_contracts, dependent: :destroy
  has_many :student_vacancies, dependent: :destroy
  accepts_nested_attributes_for :tutorial_contracts, :group_contracts, :student_vacancies

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
    other: 99
  }

  def self.new(attributes)
    attributes[:tutorial_contracts] ||= new_tutorial_contracts
    attributes[:group_contracts] ||= new_group_contracts
    attributes[:student_vacancies] ||= new_student_vacancies
    super(attributes)
  end

  private

  def new_tutorial_contracts
    term.term_tutorials.map { |term_tutorial| { term_id: term.id, term_tutorial_id: term_tutorial.id } }
  end

  def new_group_contracts
    term.term_groups.map { |term_group| { term_id: term.id, term_group_id: term_group.id } }
  end

  def new_student_vacancies
    term.timetables.map { |timetable| { timetable_id: timetable.id } }
  end
end
