FactoryBot.define do
  factory :room do
    id              { 1 }
    roomname        { 'roomname' }
    zip             { '123-4567' }
    address         { 'address' }
    mail            { 'sample@sample.com' }
    tel             { '012-3456-7890' }
    fax             { '012-0987-6543' }
    login_id        { 'login_id_1234' }
    password_digest { 'password_digest' }
  end
end
