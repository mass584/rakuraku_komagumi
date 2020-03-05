class Studentrequest < ApplicationRecord
  belongs_to :schedulemaster
  belongs_to :student
  belongs_to :timetable
  validates :schedulemaster_id,
            uniqueness: { scope: [:student_id, :timetable_id] }

  def self.get_studentrequests(student_id, schedulemaster)
    studentrequests = Hash.new { |h, k| h[k] = {} }
    schedulemaster.date_array.each do |d|
      schedulemaster.class_array.each do |c|
        studentrequests[d][c] = joins(:timetable).find_by(
          schedulemaster_id: schedulemaster.id,
          student_id: student_id,
          'timetables.scheduledate': d,
          'timetables.classnumber': c,
        )
      end
    end
    studentrequests
  end
end
