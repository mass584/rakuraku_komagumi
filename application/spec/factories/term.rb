FactoryBot.define do
  factory :spring_term, class: Term do
    association :room, factory: :room
    id        { 1 }
    name      { '2020年度春期講習' }
    year      { 2020 }
    term_type { 1 }
    begin_at  { '2020-03-30' }
    end_at    { '2020-04-12' }
    periods   { 6 }
    seats     { 7 }
    positions { 2 }
  end

  factory :first_term, class: Term do
    association :room, factory: :room
    id        { 2 }
    name      { '2020年度1学期' }
    year      { 2020 }
    term_type { 0 }
    begin_at  { '2020-04-13' }
    end_at    { '2020-07-26' }
    periods   { 6 }
    seats     { 7 }
    positions { 2 }
  end

  factory :summer_term, class: Term do
    association :room, factory: :room
    id        { 3 }
    name      { '2020年度夏期講習' }
    year      { 2020 }
    term_type { 1 }
    begin_at  { '2020-07-27' }
    end_at    { '2020-08-30' }
    periods   { 6 }
    seats     { 7 }
    positions { 2 }
  end

  factory :second_term, class: Term do
    association :room, factory: :room
    id        { 4 }
    name      { '2020年度2学期' }
    year      { 2020 }
    term_type { 0 }
    begin_at  { '2020-08-31' }
    end_at    { '2020-12-20' }
    periods   { 6 }
    seats     { 7 }
    positions { 2 }
  end

  factory :winter_term, class: Term do
    association :room, factory: :room
    id        { 5 }
    name      { '2020年度冬期講習' }
    year      { 2020 }
    term_type { 1 }
    begin_at  { '2020-12-21' }
    end_at    { '2021-01-10' }
    periods   { 6 }
    seats     { 7 }
    positions { 2 }
  end

  factory :third_term, class: Term do
    association :room, factory: :room
    id        { 6 }
    name      { '2020年度3学期' }
    year      { 2020 }
    term_type { 0 }
    begin_at  { '2021-01-11' }
    end_at    { '2021-03-21' }
    periods   { 6 }
    seats     { 7 }
    positions { 2 }
  end

  factory :exam_planning_term, class: Term do
    association :room, factory: :room
    id        { 7 }
    name      { 'テスト対策' }
    year      { 2020 }
    term_type { 2 }
    begin_at  { '2021-01-01' }
    end_at    { '2021-01-03' }
    periods   { 4 }
    seats     { 7 }
    positions { 2 }
  end
end
