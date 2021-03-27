class TermStudent < ApplicationRecord
  belongs_to :term
  belongs_to :student
  has_many :tutorial_contracts, dependent: :destroy
  has_many :group_contracts, dependent: :destroy
  has_many :student_vacancies, dependent: :destroy

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

  before_create :set_nest_objects

  private

  def set_nest_objects
    self.tutorial_contracts = new_tutorial_contracts
    self.group_contracts = new_group_contracts
    self.student_vacancies = new_student_vacancies
  end

  def new_tutorial_contracts
    term.term_tutorials.map do |term_tutorial|
      TutorialContract.new({ term_id: term.id, term_tutorial_id: term_tutorial.id }) 
    end
  end

  def new_group_contracts
    term.term_groups.map do |term_group|
      GroupContract.new({ term_id: term.id, term_group_id: term_group.id })
    end
  end

  def new_student_vacancies
    term.timetables.map do |timetable|
      StudentVacancy.new({ timetable_id: timetable.id })
    end
  end
end
