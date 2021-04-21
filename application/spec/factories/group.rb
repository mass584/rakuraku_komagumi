FactoryBot.define do
  factory :group, class: Group do
    association :room, factory: :room
    sequence(:id)    { |n| n }
    sequence(:name)  { |n| "集団科目#{n}" }
    sequence(:short_name)  { '集' }
    sequence(:order) { |n| n }
    is_deleted       { false }
  end
end
