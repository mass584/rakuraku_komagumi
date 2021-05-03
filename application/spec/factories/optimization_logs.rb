FactoryBot.define do
  factory :optimization_log do
    association :term, factory: :spring_term
  end
end
