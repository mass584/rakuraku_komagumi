class TeacherVacancy < ApplicationRecord
  belongs_to :term_teacher
  belongs_to :timetable

  validates :is_vacant,
            exclusion: { in: [nil], message: 'にnilは許容されません' }
  validate :verify_vacancy,
           on: :update,
           if: :will_save_change_to_is_vacant?

  def self.new(attributes = {})
    attributes[:is_vacant] ||= true
    super(attributes)
  end

  private

  def verify_vacancy
    if !is_vacant && timetable.seats.exists?(term_teacher_id: term_teacher_id)
      errors.add(:base, '講師の予定がすでに埋まっています')
    end
  end
end
