FactoryBot.define do
  factory :term_tutorial, class: TermTutorial do
    association :tutorial, factory: :tutorial
    association :term, factory: :spring_term
    id { 1 }
  end
end
