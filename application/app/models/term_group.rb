class TermGroup < ApplicationRecord
  belongs_to :term
  belongs_to :group
  has_many :term_group_term_teachers, dependent: :destroy
  has_many :term_teachers, through: :term_group_term_teachers
  has_many :group_contracts, dependent: :restrict_with_exception
  has_many :timetables, dependent: :nullify

  validate :tutorial_piece_empty?

  before_create :set_nest_objects

  scope :ordered, lambda {
    joins(:group).order('groups.order': 'ASC')
  }
  scope :named, lambda {
    joins(:group).select('term_groups.*', 'groups.name')
  }

  def editable
    !term.tutorial_pieces.filter_by_placed.exists?
  end

  private

  def tutorial_piece_empty?
    unless editable
      errors.add(:base, 'コマが配置されているため変更できません')
    end
  end

  def set_nest_objects
    self.group_contracts = new_group_contracts
  end

  def new_group_contracts
    term.term_students.map do |term_student|
      GroupContract.new({ term_id: term.id, term_student_id: term_student.id })
    end
  end
end
