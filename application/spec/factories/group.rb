FactoryBot.define do
  factory :group, class: Group do
    association :room, factory: :room
    sequence(:id)    { |n| n }
    sequence(:name)  { |n| "集団科目#{n}" }
    sequence(:order) { |n| n }
    is_deleted       { false }
    room_id          { 1 }
  end
end
