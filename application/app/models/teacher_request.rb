class TeacherRequest < ApplicationRecord
  belongs_to :term
  belongs_to :teacher
  belongs_to :timetable

  def self.get_teacher_requests(teacher_id, term)
    term.date_array.reduce({}) do |accu_d, date|
      accu_d.merge({
        date.to_s => term.period_array.reduce({}) do |accu_p, period|
          accu_p.merge({
            period.to_s => joins(:timetable).find_by(
              term_id: term.id,
              teacher_id: teacher_id,
              'timetables.date': date,
              'timetables.period': period,
            ),
          })
        end,
      })
    end
  end
end
