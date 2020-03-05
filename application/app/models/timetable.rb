class Timetable < ApplicationRecord
  belongs_to :schedulemaster
  validates :schedulemaster_id,
            uniqueness: { scope: [:scheduledate, :classnumber] }

  def self.get_timetables(schedulemaster)
    timetables = Hash.new { |h, k| h[k] = {} }
    schedulemaster.date_array.each do |date|
      schedulemaster.period_array.each do |period|
        timetables[date][period] = find_by(
          schedulemaster_id: schedulemaster.id,
          date: date,
          period: period,
        )
      end
    end
    timetables
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
end
