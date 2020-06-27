class Teacherrequest < ApplicationRecord
  belongs_to :schedulemaster
  belongs_to :teacher
  belongs_to :timetable
  validates :schedulemaster_id,
            presence: true,
            uniqueness: { scope: [:teacher_id, :timetable_id] }
  validates :teacher_id,
            presence: true
  validates :timetable_id,
            presence: true

  def self.get_teacherrequests(teacher_id, schedulemaster)
    schedulemaster.date_array.reduce({}) do |accu_d, date|
      accu_d.merge({
        "#{date}" => schedulemaster.period_array.reduce({}) do |accu_p, period|
          accu_p.merge({
            "#{period}" => joins(:timetable).find_by(
              schedulemaster_id: schedulemaster.id,
              teacher_id: teacher_id,
              'timetables.date': date,
              'timetables.period': period,
            )
          })
        end
      })
    end
  end
end
