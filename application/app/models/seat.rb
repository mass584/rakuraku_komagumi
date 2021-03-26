class Seat < ApplicationRecord
  belongs_to :term
  belongs_to :timetable
  belongs_to :teacher_term, optional: true
  has_many :pieces, dependent: :destroy

  validates :number, presence: true
  validate :can_change_teacher_term_id?,
           on: :update,
           if: :will_save_change_to_teacher_term_id?

  def self.new(attributes)
    attributes[:term_teacher_id] ||= nil
    super(attributes)
  end

  def self.duplicated?(timetable_id, teacher_term_id)
    self.class.where(timetable_id: timetable_id, teacher_term_id: teacher_term_id).exists?
  end

  private

  def can_change_teacher_term_id?
    if teacher_term.present? && pieces.exist? 
      errors[:base] << '授業が割り当てられているため変更できません'
    end

    if teacher_term.present? && self.duplicated?(timetable_id, teacher_term_id)
      errors[:base] << '講師が他の席に割り当てられています'
    end
  end
end
