FactoryBot.define do
  factory :subject_schedulemaster_mapping, class: SubjectSchedulemasterMapping do
    id                { 1 }
    schedulemaster_id { 1 }
    subject_id        { 1 }
    teacher_id        { 0 }
  end
end
