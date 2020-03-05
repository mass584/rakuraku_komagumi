FactoryBot.define do
  factory :timetable, class: Timetable do
    id                { 1 }
    schedulemaster_id { 1 }
    scheduledate      { '2019-01-01' }
    classnumber       { 1 }
    status            { 0 }
  end
end
