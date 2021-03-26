class TermGroup < ApplicationRecord
  belongs_to :term
  belongs_to :group
  belongs_to :term_teacher, optional: true
  has_many :group_contracts, dependent: :restrict_with_exception
  accepts_nested_attributes_for :group_contracts

  def self.new(attributes)
    attributes[:group_contracts] ||= new_group_contracts
    super(attributes)
  end

  private

  def new_group_contracts 
    term.term_students.map do |term_student|
      { term_id: term.id, term_student_id: term_student.id }
    end
  end
end
