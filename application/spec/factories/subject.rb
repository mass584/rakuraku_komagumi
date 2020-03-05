FactoryBot.define do
  factory :subject, class: Subject do
    id         { 1 }
    name       { 'name' }
    classtype  { '個別授業' }
    row_order  { 1 }
    is_deleted { false }
    room_id    { 1 }
  end
end
