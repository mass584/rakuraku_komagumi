FactoryBot.define do
  factory :term_group, class: TermGroup do
    association :group, factory: :group
    association :term, factory: :spring_term
  end
end
