class Timetable < ApplicationRecord
  belongs_to :term
  validate :can_update_status?, on: :update, if: :status_changed?
  enum status: { opened: 0, closed: 1 }

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
        create(
          term_id: term.id,
          date: date,
          period: period,
          status: 0,
        )
      end
    end
  end

  private

  def can_update_status?
    if term.pieces.where(timetable_id: id).count.positive?
      errors[:base] << '既に授業が割り当てられているので、変更できません。'
    end
  end
end
