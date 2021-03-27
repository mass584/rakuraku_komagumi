FactoryBot.define do
  factory :teacher, class: Teacher do
    association :room, factory: :room
    id           { 1 }
    name         { '講師名' }
    email        { 'teacher@example.com' }
    is_deleted   { false }
  end
end
