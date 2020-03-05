FactoryBot.define do
  factory :classnumber, class: Classnumber do
    id                { 1 }
    schedulemaster_id { 1 }
    teacher_id        { 1 }
    student_id        { 1 }
    subject_id        { 1 }
    number            { 0 }
  end
end
