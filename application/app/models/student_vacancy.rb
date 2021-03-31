class StudentVacancy < ApplicationRecord
  belongs_to :term_student
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
    if !is_vacant &&
       timetable.seats.map(&:tutorial_pieces).flatten.find { |tutorial_piece| tutorial_piece.tutorial_contract.term_student_id == term_student_id }
      errors[:base] << '生徒の予定がすでに埋まっています'
    end
  end
end
