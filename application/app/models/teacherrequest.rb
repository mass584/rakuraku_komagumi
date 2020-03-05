class Teacherrequest < ApplicationRecord
  belongs_to :schedulemaster
  belongs_to :teacher
  belongs_to :timetable
  validates :schedulemaster_id,
            uniqueness: { scope: [:teacher_id, :timetable_id] }

  def self.get_teacherrequests(teacher_id, schedulemaster)
    teacherrequests = Hash.new { |h, k| h[k] = {} }
    schedulemaster.date_array.each do |d|
      schedulemaster.class_array.each do |c|
        teacherrequests[d][c] = joins(:timetable).find_by(
          schedulemaster_id: schedulemaster.id,
          teacher_id: teacher_id,
          'timetables.scheduledate': d,
          'timetables.classnumber': c,
        )
      end
    end
    teacherrequests
  end
end
