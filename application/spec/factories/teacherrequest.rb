FactoryBot.define do
  factory :teacherrequest, class: Teacherrequest do
    id                { 1 }
    schedulemaster_id { 1 }
    teacher_id        { 1 }
    timetable_id      { 1 }
  end
end
