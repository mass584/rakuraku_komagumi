class TermTutorial < ApplicationRecord
  belongs_to :term
  belongs_to :tutorial
  has_many :tutorial_contracts, dependent: :restrict_with_exception

  before_create :set_nest_objects

  scope :ordered, lambda {
    joins(:tutorial).order('tutorials.order': 'ASC')
  }
  scope :named, lambda {
    eager_load(:tutorial).select('term_tutorials.*', 'tutorials.name')
  }

  private

  def set_nest_objects
    self.tutorial_contracts = new_tutorial_contracts
  end

  def new_tutorial_contracts
    term.term_students.map do |term_student|
      TutorialContract.new({ term_id: term.id, term_student_id: term_student.id })
    end
  end
end
