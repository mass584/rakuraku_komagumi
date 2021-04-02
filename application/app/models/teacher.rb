class Teacher < ApplicationRecord
  belongs_to :room
  has_many :term_teachers, dependent: :restrict_with_exception

  validates :name,
            length: { minimum: 1, maximum: 20 }
  validates :email,
            format: { with: /\A([^@\s]+)@(([-a-z0-9]+\.)+[a-z]{2,})\z/ }

  scope :active, -> { where(is_deleted: false) }
  scope :sorted, -> { order(name: 'ASC') }
  scope :matched, ->(keyword) { where('name like ?', "%#{sanitize_sql_like(keyword || '')}%") }
  scope :paginated, ->(page) { slice((page - 1) * 20, 20) }
  scope :searched, ->(keyword, page) { active.sorted.matched(keyword).paginated(page) }
end
