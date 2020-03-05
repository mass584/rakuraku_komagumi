FactoryBot.define do
  factory :studentrequestmaster, class: Studentrequestmaster do
    id                { 1 }
    schedulemaster_id { 1 }
    student_id        { 1 }
    status            { 1 }
  end
end
