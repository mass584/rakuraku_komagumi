FactoryBot.define do
  factory :schedule, class: Schedule do
    id                { 1 }
    schedulemaster_id { 1 }
    student_id        { 1 }
    teacher_id        { 1 }
    subject_id        { 1 }
    timetable_id      { 1 }
    status            { 1 }
  end
end
