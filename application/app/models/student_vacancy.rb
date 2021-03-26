class StudentVacancy < ApplicationRecord
  belongs_to :term
  belongs_to :term_student
  belongs_to :timetable

  validates :is_vacant,
            exclusion: { in: [nil], message: 'にnilは許容されません' }
end
