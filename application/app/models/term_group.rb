class TermGroup < ApplicationRecord
  belongs_to :term
  belongs_to :group
  belongs_to :term_teacher, optional: true
  has_many :group_contracts, dependent: :restrict_with_exception
  accepts_nested_attributes_for :group_contracts

  def self.new(attributes)
    super(attributes)
    self.group_contracts ||= new_group_contracts
  end

  private

  def new_group_contracts 
    term.term_students.map do |term_student|
      {
        term_id: term.id,
        term_student_id: term_student.id,
        is_contracted: false,
      }
    end
  end
end
