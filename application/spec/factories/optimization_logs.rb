FactoryBot.define do
  factory :optimization_log do
    sequence_number { 1 }
    installation_progress { 0 }
    swapping_progress     { 1 }
    deletion_progress     { 0 }
    exit_status           { 0 }
    end_at                { nil }
  end
end
