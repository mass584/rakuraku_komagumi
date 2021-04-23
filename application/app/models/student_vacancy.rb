class StudentVacancy < ApplicationRecord
  belongs_to :term_student
  belongs_to :timetable

  validates :is_vacant,
            exclusion: { in: [nil], message: 'にnilは許容されません' }
  validate :verify_vacancy,
           on: :update,
           if: :will_save_change_to_is_vacant?

  scope :indexed, lambda {
    joins(:timetable).select(
      'student_vacancies.*',
      'timetables.date_index',
      'timetables.period_index',
    )
  }

  def self.new(attributes = {})
    attributes[:is_vacant] ||= true
    super(attributes)
  end

  private

  def verify_vacancy
    term_student_ids = timetable.seats.joins(
      tutorial_pieces: :tutorial_contract,
    ).pluck(:term_student_id).flatten.uniq
    if !is_vacant && term_student_ids.find { |item| item == term_student_id }
      errors.add(:base, '生徒の予定がすでに埋まっています')
    end
  end
end
