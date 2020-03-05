FactoryBot.define do
  factory :schedulemaster do
    id                   { 1 }
    schedule_name        { 'schedule_name' }
    schedule_type        { 'schedule_type' }
    begindate            { '2019-01-01' }
    enddate              { '2019-01-31' }
    totalclassnumber     { 6 }
    seatnumber           { 6 }
    calculation_status   { 0 }
    calculation_name     { 'calculation_name' }
    calculation_begin    { '2019-01-01 12:00:00.00000' }
    calculation_end      { '2019-01-01 13:00:00.00000' }
    calculation_result   { 'calculation_result' }
    calculation_progress { 0 }
    max_count            { 50 }
    max_time_sec         { 0 }
    room_id              { 1 }
  end
end
