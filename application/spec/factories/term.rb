FactoryBot.define do
  factory :spring_term, class: Term do
    association :room, factory: :room
    name           { '2020年度春期講習' }
    year           { 2020 }
    term_type      { 1 }
    begin_at       { '2020-03-30' }
    end_at         { '2020-04-12' }
    period_count   { 6 }
    seat_count     { 7 }
    position_count { 2 }
  end

  factory :first_term, class: Term do
    association :room, factory: :room
    name           { '2020年度1学期' }
    year           { 2020 }
    term_type      { 0 }
    begin_at       { '2020-04-13' }
    end_at         { '2020-07-26' }
    period_count   { 6 }
    seat_count     { 7 }
    position_count { 2 }
  end

  factory :summer_term, class: Term do
    association :room, factory: :room
    name           { '2020年度夏期講習' }
    year           { 2020 }
    term_type      { 1 }
    begin_at       { '2020-07-27' }
    end_at         { '2020-08-30' }
    period_count   { 6 }
    seat_count     { 7 }
    position_count { 2 }
  end

  factory :second_term, class: Term do
    association :room, factory: :room
    name           { '2020年度2学期' }
    year           { 2020 }
    term_type      { 0 }
    begin_at       { '2020-08-31' }
    end_at         { '2020-12-20' }
    period_count   { 6 }
    seat_count     { 7 }
    position_count { 2 }
  end

  factory :winter_term, class: Term do
    association :room, factory: :room
    name           { '2020年度冬期講習' }
    year           { 2020 }
    term_type      { 1 }
    begin_at       { '2020-12-21' }
    end_at         { '2021-01-10' }
    period_count   { 6 }
    seat_count     { 7 }
    position_count { 2 }
  end

  factory :third_term, class: Term do
    association :room, factory: :room
    name           { '2020年度3学期' }
    year           { 2020 }
    term_type      { 0 }
    begin_at       { '2021-01-11' }
    end_at         { '2021-03-21' }
    period_count   { 6 }
    seat_count     { 7 }
    position_count { 2 }
  end

  factory :exam_planning_term, class: Term do
    association :room, factory: :room
    name           { 'テスト対策' }
    year           { 2020 }
    term_type      { 2 }
    begin_at       { '2021-01-01' }
    end_at         { '2021-01-03' }
    period_count   { 4 }
    seat_count     { 7 }
    position_count { 2 }
  end
end
