class Student < ApplicationRecord
  belongs_to :room
  has_many :term_students, dependent: :restrict_with_exception

  validates :name,
            length: { minimum: 1, maximum: 20 }
  validates :email,
            format: { with: /\A([^@\s]+)@(([-a-z0-9]+\.)+[a-z]{2,})\z/ }

  enum school_grade: {
    e1: 11,
    e2: 12,
    e3: 13,
    e4: 14,
    e5: 15,
    e6: 16,
    j1: 21,
    j2: 22,
    j3: 23,
    h1: 31,
    h2: 32,
    h3: 33,
    other: 99
  }

  scope :active, -> { where(is_deleted: false) }
  scope :sorted, -> { order(school_grade: 'ASC', name: 'ASC') }
  scope :matched, ->(keyword) { where('name like ?', "%#{sanitize_sql_like(keyword || '')}%") }
  scope :paginated, ->(page) { slice((page - 1) * 20, 20) }
  scope :searched, ->(keyword, page) { active.sorted.matched(keyword).paginated(page) }
end
