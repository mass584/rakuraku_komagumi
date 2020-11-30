class Teacher < ApplicationRecord
  belongs_to :room
  has_many :teacher_terms, dependent: :restrict_with_exception
  has_many :terms, through: :teacher_terms

  validates :email,
            allow_blank: true,
            format: { with: /\A([^@\s]+)@(([-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :tel,
            allow_blank: true,
            format: { with: /\A0[0-9]{1,3}-[0-9]{1,4}-[0-9]{1,4}\z/ }
  validates :zip,
            allow_blank: true,
            format: { with: /\A[0-9]{3}-[0-9]{4}\z/ }
  validate :verify_maximum, on: :create

  scope :active, -> { where(is_deleted: false) }
  scope :sorted, -> { order(name: 'ASC') }
  scope :matched, ->(keyword) { where('name like ?', "%#{sanitize_sql_like(keyword || '')}%") }
  scope :paginated, ->(page) { slice((page - 1) * 10, page * 10) }
  scope :searched, ->(keyword, page) { active.sorted.matched(keyword).paginated(page) }

  private

  def verify_maximum
    if Teacher.where(room_id: room.id, is_deleted: false).count >= 60
      errors[:base] << '登録可能な上限数を超えています。'
    end
  end
end
