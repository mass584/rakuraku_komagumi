FactoryBot.define do
  factory :term_student, class: TermStudent do
    association :student, factory: :student
    association :term, factory: :spring_term
    school_grade { 21 }
  end
end
