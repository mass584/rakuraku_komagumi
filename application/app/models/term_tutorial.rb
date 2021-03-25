class TermTutorial < ApplicationRecord
  belongs_to :term
  belongs_to :tutorial
  has_many :tutorial_contracts, dependent: :restrict_with_exception
  accepts_nested_attributes_for :tutorial_contracts

  def self.new(attributes)
    super(attributes)
    self.tutorial_contracts ||= new_tutorial_contracts
  end

  private

  def new_tutorial_contracts 
    term.term_students.map do |term_student|
      {
        term_id: term.id,
        term_student_id: term_student.id,
        term_teacher_id: nil,
        piece_count: 0,
      }
    end
  end
end
