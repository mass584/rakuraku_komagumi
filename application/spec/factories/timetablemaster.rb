FactoryBot.define do
  factory :timetablemaster, class: Timetablemaster do
    id                { 1 }
    schedulemaster_id { 1 }
    classnumber       { 1 }
    begin_at          { '00:00:00' }
    end_at            { '00:00:00' }
  end
end
