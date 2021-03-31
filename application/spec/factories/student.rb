FactoryBot.define do
  factory :student, class: Student do
    association :room, factory: :room
    sequence(:name) { |n| "生徒#{n}" }
    email           { 'student@example.com' }
    school_grade    { 21 }
    is_deleted      { false }
  end
end
