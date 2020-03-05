class Studentrequest < ApplicationRecord
  belongs_to :schedulemaster
  belongs_to :student
  belongs_to :timetable
  validates :schedulemaster_id,
            presence: true,
            uniqueness: { scope: [:student_id, :timetable_id] }
  validates :student_id,
            presence: true
  validates :timetable_id,
            presence: true

  def self.get_studentrequests(student_id, schedulemaster)
    studentrequests = Hash.new { |h, k| h[k] = {} }
    schedulemaster.date_array.each do |date|
      schedulemaster.period_array.each do |period|
        studentrequests[date][period] = joins(:timetable).find_by(
          schedulemaster_id: schedulemaster.id,
          student_id: student_id,
          'timetables.date': date,
          'timetables.period': period,
        )
      end
    end
    studentrequests
  end
end
