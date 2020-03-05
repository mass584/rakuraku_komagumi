FactoryBot.define do
  factory :teacher, class: Teacher do
    id              { 1 }
    lastname        { 'lastname' }
    firstname       { 'firstname' }
    lastname_kana   { 'しめい' }
    firstname_kana  { 'しめい' }
    zip             { '123-4567' }
    address         { 'address' }
    mail            { 'sample@sample.com' }
    tel             { '012-3456-7890' }
    is_deleted      { false }
    room_id         { 1 }
  end
end
