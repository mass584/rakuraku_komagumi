class TermGroup < ApplicationRecord
  belongs_to :term
  belongs_to :group
  belongs_to :term_teacher, optional: true
  has_many :group_contracts, dependent: :restrict_with_exception
  has_many :timetables, dependent: :nullify

  validate :can_update_term_teacher?,
           on: :update,
           if: :will_save_change_to_term_teacher_id?

  before_create :set_nest_objects

  private

  # validate
  def can_update_term_teacher?
    unless term.seats.filter_by_occupied.zero?
      errors[:base] << '集団担当を変更するには、個別授業の設定を全て解除する必要があります'
    end
  end

  # before_create
  def set_nest_objects
    self.group_contracts = new_group_contracts
  end

  def new_group_contracts 
    term.term_students.map do |term_student|
      GroupContract.new({ term_id: term.id, term_student_id: term_student.id })
    end
  end
end
