class Timetablemaster < ApplicationRecord
  belongs_to :schedulemaster
  validates :schedulemaster_id,
            uniqueness: { scope: [:classnumber] }

  def self.get_timetablemasters(schedulemaster)
    timetablemasters = Hash.new{}
    schedulemaster.class_array.each do |c|
      timetablemasters[c] = find_by(
        schedulemaster_id: schedulemaster.id,
        classnumber: c,
      )
    end
    timetablemasters
  end

  def self.bulk_create(schedulemaster)
    schedulemaster.class_array.each do |c|
      Timetablemaster.create(
        schedulemaster_id: schedulemaster.id,
        classnumber: c,
        begintime: '2000-01-01 00:00:00',
        endtime: '2000-01-01 00:00:00',
      )
    end
  end
end
