class Timetable < ApplicationRecord
  belongs_to :term
  has_many :student_requests, dependent: :destroy
  has_many :teacher_requests, dependent: :destroy
  has_many :seats, dependent: :destroy
  validate :can_update_is_closed?, on: :update, if: :will_save_change_to_is_closed?

  def self.get_timetables(term)
    where(term_id: term.id).reduce({}) do |accu, item|
      accu.deep_merge({
        item.date => {
          item.period => item,
        },
      })
    end
  end

  def self.bulk_create(term)
    term.date_array.each do |date|
      term.period_array.each do |period|
        create(term_id: term.id, date: date, period: period)
      end
    end
  end

  private

  def can_update_is_closed?
    if seats.filter { |seat| seat.pieces.exists? }.count.positive?
      errors[:base] << '座席が割り当てられているので、変更できません。'
    end
  end
end
