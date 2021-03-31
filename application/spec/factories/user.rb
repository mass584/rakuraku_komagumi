FactoryBot.define do
  factory :user, class: User do
    name  { 'ユーザー名' }
    email { 'user@example.com' }
  end
end
