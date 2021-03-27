FactoryBot.define do
  factory :term_group, class: TermGroup do
    association :group, factory: :group
    association :term, factory: :spring_term
    id              { 1 }
    term_teacher_id { nil }
  end
end
