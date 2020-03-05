FactoryBot.define do
  factory :timetablemaster, class: Timetablemaster do
    id                { 1 }
    schedulemaster_id { 1 }
    classnumber       { 1 }
    begintime         { '00:00:00' }
    endtime           { '00:00:00' }
  end
end
