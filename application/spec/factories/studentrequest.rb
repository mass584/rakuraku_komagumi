FactoryBot.define do
  factory :studentrequest, class: Studentrequest do
    id                { 1 }
    schedulemaster_id { 1 }
    student_id        { 1 }
    timetable_id      { 1 }
  end
end
