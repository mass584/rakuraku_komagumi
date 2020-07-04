class TeacherRequest < ApplicationRecord
  belongs_to :term
  belongs_to :teacher
  belongs_to :timetable

  def self.get_teacher_requests(teacher_term, term)
    teacher_requests = where(
      term_id: term.id,
      teacher_id: teacher_term.teacher_id,
    )
    term.timetables.reduce({}) do |accu, item|
      accu.deep_merge({
        item.date => {
          item.period => teacher_requests.find do |teacher_request|
            item.id == teacher_request.timetable_id
          end,
        },
      })
    end
  end
end
