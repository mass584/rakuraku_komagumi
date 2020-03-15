class Timetable < ApplicationRecord
  belongs_to :schedulemaster
  validates :schedulemaster_id,
            presence: true,
            uniqueness: { scope: [:date, :period] }
  validates :date,
            presence: true
  validates :period,
            presence: true
  validates :status,
            presence: true
  validate :can_update_status?, on: :update, if: :status_changed?

  def self.get_timetables(schedulemaster)
    schedulemaster.date_array.reduce({}) do |accu_d, date|
      accu_d.merge({
        "#{date}" => schedulemaster.period_array.reduce({}) do |accu_p, period|
          accu_p.merge({
            "#{period}" => find_by(
              schedulemaster_id: schedulemaster.id,
              date: date,
              period: period
            )
          })
        end
      })
    end
  end

  def self.bulk_create(schedulemaster)
    schedulemaster.date_array.each do |date|
      schedulemaster.period_array.each do |period|
        create(
          schedulemaster_id: schedulemaster.id,
          date: date,
          period: period,
          status: 0,
        )
      end
    end
  end

  private

  def can_update_status?
    if schedulemaster.schedules.where(timetable_id: id).count.positive?
      errors[:base] << '既に授業が割り当てられているので、変更できません。'
    end
  end
end
