FactoryBot.define do
  factory :group, class: Group do
    association :room, factory: :room
    id         { 1 }
    name       { '集団科目名' }
    order      { 1 }
    is_deleted { false }
    room_id    { 1 }
  end
end
