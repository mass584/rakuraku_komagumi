FactoryBot.define do
  factory :teacherrequestmaster, class: Teacherrequestmaster do
    id                { 1 }
    schedulemaster_id { 1 }
    teacher_id        { 1 }
    status            { 1 }
  end
end
