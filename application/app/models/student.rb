class Student < ApplicationRecord
  belongs_to :room
  has_many :term_students, dependent: :restrict_with_exception

  validates :name,
            length: { minimum: 1, maximum: 20 }
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

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
    other: 99,
  }

  scope :active, -> { where(is_deleted: false) }
  scope :ordered, -> { order(school_grade: 'ASC', name: 'ASC') }
  scope :matched, lambda { |keyword|
    keyword.instance_of?(String) && keyword.present? ?
      where('name like ?', "%#{sanitize_sql_like(keyword)}%") :
      itself
  }
  scope :pagenated, lambda { |page, page_size|
    page.instance_of?(Integer) && page_size.instance_of?(Integer) ?
      offset((page - 1) * page_size).limit(page_size) :
      itself
  }
end
