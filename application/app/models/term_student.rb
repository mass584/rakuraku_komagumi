class TermStudent < ApplicationRecord
  belongs_to :term
  belongs_to :student
  has_many :tutorial_contracts, dependent: :destroy
  has_many :group_contracts, dependent: :destroy
  has_many :student_vacancies, dependent: :destroy
  accepts_nested_attributes_for [:tutorial_contracts, :group_contracts, :student_vacancies]

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
    super(attributes)
    self.tutorial_contracts ||= new_tutorial_contracts
    self.group_contracts ||= new_group_contracts
    self.student_vacancies ||= new_student_vacancies
  end

  private

  def new_tutorial_contracts
    term.tutorials.map do |tutorial|
      { 
        term_id: term.id,
        term_tutorial_id: tutorial.id,
        term_teacher_id: nil,
        piece_count: 0
      }
    end
  end

  def new_group_contracts
    term.groups.map do |group|
      { 
        term_id: term.id,
        term_group_id: group.id,
        is_contracted: false
      }
    end
  end

  def new_student_vacancies
    term.timetables.map do |timetable|
      {
        timetable_id: timetable.id,
        is_vacant: false
      }
    end
  end
end
