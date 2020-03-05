class Timetable < ApplicationRecord
  belongs_to :schedulemaster
  validates :schedulemaster_id,
            uniqueness: { scope: [:scheduledate, :classnumber] }

  def self.get_timetables(schedulemaster)
    timetables = Hash.new { |h, k| h[k] = {} }
    schedulemaster.date_array.each do |d|
      schedulemaster.class_array.each do |c|
        timetables[d][c] = find_by(
          schedulemaster_id: schedulemaster.id,
          scheduledate: d,
          classnumber: c,
        )
      end
    end
    timetables
  end

  def self.bulk_create(schedulemaster)
    schedulemaster.date_array.each do |d|
      schedulemaster.class_array.each do |c|
        create(
          schedulemaster_id: schedulemaster.id,
          scheduledate: d,
          classnumber: c,
          status: 0,
        )
      end
    end
  end
end
