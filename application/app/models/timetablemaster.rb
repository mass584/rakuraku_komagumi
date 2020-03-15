class Timetablemaster < ApplicationRecord
  belongs_to :schedulemaster
  validates :schedulemaster_id,
            presence: true,
            uniqueness: { scope: [:period] }
  validates :period,
            presence: true

  def self.get_timetablemasters(schedulemaster)
    schedulemaster.period_array.reduce({}) do |accu, period|
      accu.merge({
        "#{period}" => find_by(
          schedulemaster_id: schedulemaster.id,
          period: period,
        )
      })
    end
  end

  def self.bulk_create(schedulemaster)
    schedulemaster.period_array.each do |period|
      Timetablemaster.create(
        schedulemaster_id: schedulemaster.id,
        period: period,
        begin_at: '18:00',
        end_at: '18:00',
      )
    end
  end
end
