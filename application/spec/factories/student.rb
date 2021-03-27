FactoryBot.define do
  factory :student, class: Student do
    association :room, factory: :room
    id           { 1 }
    name         { '生徒名' }
    email        { 'student@example.com' }
    school_grade { 21 }
    is_deleted   { false }
  end
end
