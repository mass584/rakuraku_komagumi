class StudentRequest < ApplicationRecord
  belongs_to :term
  belongs_to :student
  belongs_to :timetable

  def self.get_student_requests(student_id, term_id)
    student_requests = where(term_id: term_id, student_id: student_id)
    term.timetables.reduce({}) do |accu, item|
      accu.deep_merge({
        item.date => {
          item.period => student_requests.include? do |student_request|
            item.id == student_request.timetable_id
          end,
        },
      })
    end
  end
end
