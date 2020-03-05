FactoryBot.define do
  factory :student_schedulemaster_mapping, class: StudentSchedulemasterMapping do
    id                { 1 }
    schedulemaster_id { 1 }
    student_id        { 1 }
    grade             { '中1' }
  end
end
