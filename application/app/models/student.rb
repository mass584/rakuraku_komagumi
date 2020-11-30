class Student < ApplicationRecord
  belongs_to :room
  has_many :student_terms, dependent: :restrict_with_exception
  has_many :terms, through: :student_terms

  validates :email,
            allow_blank: true,
            format: { with: /\A([^@\s]+)@(([-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :tel,
            allow_blank: true,
            format: { with: /\A0[0-9]{1,3}-[0-9]{1,4}-[0-9]{1,4}\z/ }
  validates :zip,
            allow_blank: true,
            format: { with: /\A[0-9]{3}-[0-9]{4}\z/ }
  validates :school_grade,
            presence: true
  validates :gender,
            presence: true
  validate :verify_maximum, on: :create
  enum gender: { male: 1, female: 2 }
  enum school_grade: { e1: 1, e2: 2, e3: 3, e4: 4, e5: 5, e6: 6, j1: 11, j2: 12, j3: 13, h1: 21, h2: 22, h3: 23 }

  scope :active, -> { where(is_deleted: false) }
  scope :sorted, -> { order(school_grade: 'ASC', name: 'ASC') }
  scope :matched, ->(keyword) { where('name like ?', "%#{sanitize_sql_like(keyword || '')}%") }
  scope :paginated, ->(page) { slice((page - 1) * 10, 10) }
  scope :searched, ->(keyword, page) { active.sorted.matched(keyword).paginated(page) }

  private

  def verify_maximum
    if Student.where(room_id: room.id, is_deleted: false).count >= 60
      errors[:base] << '登録可能な上限数を超えています。'
    end
  end
end
