class TermGroup < ApplicationRecord
  belongs_to :term
  belongs_to :group
  belongs_to :term_teacher, optional: true
  has_many :group_contracts, dependent: :restrict_with_exception

  before_create :set_nest_objects

  private

  def set_nest_objects
    self.group_contracts = new_group_contracts
  end

  def new_group_contracts 
    term.term_students.map do |term_student|
      GroupContract.new({ term_id: term.id, term_student_id: term_student.id })
    end
  end
end
