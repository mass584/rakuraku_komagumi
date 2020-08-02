class Seat < ApplicationRecord
  belongs_to :term
  belongs_to :timetable
  belongs_to :teacher_term, optional: true
  has_many :pieces, dependent: :destroy

  validates :number, presence: true
  validate :can_nullify_teacher_term_id?,
           on: :update,
           if: :will_save_change_to_teacher_term_id?
  validate :verify_doublebooking,
           on: :update,
           if: :will_save_change_to_teacher_term_id?

  def self.get_seats(term)
    includes(
      timetable: [],
      teacher_term: [:teacher],
    ).where(term_id: term.id).reduce({}) do |accu, item|
      accu.deep_merge({
        item.timetable.date => {
          item.timetable.period => {
            item.number => item,
          },
        },
      })
    end
  end

  def self.bulk_create(term)
    term.timetables.each do |timetable|
      term.seat_array.each do |seat_number|
        create(
          term_id: term.id,
          timetable_id: timetable.id,
          number: seat_number,
        )
      end
    end
  end

  private

  def can_nullify_teacher_term_id?
    if pieces.exists?
      errors[:base] << '授業が割り当てられているので、変更できません。'
    end
  end

  def verify_doublebooking
    if teacher_term_id.present? && Seat.where(
      timetable_id: timetable_id,
      teacher_term_id: teacher_term_id,
    ).exists?
      errors[:base] << '講師が他の席に割り当てられています。'
    end
  end
end
