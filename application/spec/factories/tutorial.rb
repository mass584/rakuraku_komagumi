FactoryBot.define do
  factory :tutorial, class: Tutorial do
    association :room, factory: :room
    sequence(:id)    { |n| n }
    sequence(:name)  { |n| "個別科目#{n}" }
    sequence(:short_name)  { '個' }
    sequence(:order) { |n| n }
    is_deleted       { false }
  end
end
