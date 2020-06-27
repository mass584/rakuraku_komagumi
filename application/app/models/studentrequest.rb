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
    schedulemaster.date_array.reduce({}) do |accu_d, date|
      accu_d.merge({
        "#{date}" => schedulemaster.period_array.reduce({}) do |accu_p, period|
          accu_p.merge({
            "#{period}" => joins(:timetable).find_by(
              schedulemaster_id: schedulemaster.id,
              student_id: student_id,
              'timetables.date': date,
              'timetables.period': period,
            )
          })
        end
      })
    end
  end
end
