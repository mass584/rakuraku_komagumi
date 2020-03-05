FactoryBot.define do
  factory :calculation_rule, class: CalculationRule do
    id                { 1             }
    schedulemaster_id { 1             }
    eval_target       { 'eval_target' }
    blank_class_max   { 1             }
    blank_class_cost  { '0,0'         }
    total_class_max   { 4             }
    total_class_cost  { '0,0,0,0,0'   }
  end
end
