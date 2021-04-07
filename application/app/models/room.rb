class Room < ApplicationRecord
  has_many :students, dependent: :restrict_with_exception
  has_many :teachers, dependent: :restrict_with_exception
  has_many :tutorials, dependent: :restrict_with_exception
  has_many :groups, dependent: :restrict_with_exception
  has_many :terms, dependent: :restrict_with_exception

  validates :name,
            length: { minimum: 1, maximum: 20 }

  scope :ordered, -> { order(created_at: 'ASC') }
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
