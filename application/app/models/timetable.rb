class Timetable < ApplicationRecord
  belongs_to :term
  validate :can_update_status?, on: :update, if: :status_changed?

  def self.get_timetables(term)
    term.date_array.reduce({}) do |accu_d, date|
      accu_d.merge({
        date.to_s => term.period_array.reduce({}) do |accu_p, period|
          accu_p.merge({
            period.to_s => find_by(
              term_id: term.id,
              date: date,
              period: period,
            ),
          })
        end,
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
