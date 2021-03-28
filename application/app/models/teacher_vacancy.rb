class TeacherVacancy < ApplicationRecord
  belongs_to :term_teacher
  belongs_to :timetable

  validates :is_vacant,
            exclusion: { in: [nil], message: 'にnilは許容されません' }

  def self.new(attributes = {})
    attributes[:is_vacant] ||= false
    super(attributes)
  end
end
