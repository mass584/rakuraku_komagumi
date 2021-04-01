FactoryBot.define do
  factory :term_teacher, class: TermTeacher do
    association :teacher, factory: :teacher
    association :term, factory: :spring_term
  end
end
