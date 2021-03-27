FactoryBot.define do
  factory :tutorial, class: Tutorial do
    association :room, factory: :room
    id         { 1 }
    name       { '個別科目名' }
    order      { 1 }
    is_deleted { false }
    room_id    { 1 }
  end
end
