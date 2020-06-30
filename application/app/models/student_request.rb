class StudentRequest < ApplicationRecord
  belongs_to :term
  belongs_to :student
  belongs_to :timetable

  def self.get_student_requests(student_id, term)
    term.date_array.reduce({}) do |accu_d, date|
      accu_d.merge({
        date.to_s => term.period_array.reduce({}) do |accu_p, period|
          accu_p.merge({
            period.to_s => joins(:timetable).find_by(
              term_id: term.id,
              student_id: student_id,
              'timetables.date': date,
              'timetables.period': period,
            ),
          })
        end,
      })
    end
  end
end
