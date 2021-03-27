FactoryBot.define do
  factory :user, class: User do
    id    { 1 }
    name  { 'ユーザー名' }
    email { 'user@example.com' }
  end
end
