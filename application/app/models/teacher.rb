class Teacher < ApplicationRecord
  belongs_to :room
  has_many :teacher_subjects, dependent: :destroy
  has_many :subjects, through: :teacher_subjects
  has_many :teacher_terms, dependent: :restrict_with_exception
  has_many :terms, through: :teacher_terms
  has_many :teacher_requests, dependent: :restrict_with_exception
  has_many :contracts, dependent: :restrict_with_exception
  has_many :pieces, dependent: :restrict_with_exception
  validates :name_kana,
            presence: true,
            format: { with: /\A[\p{Hiragana}ー]+\z/ }
  validates :email,
            allow_blank: true,
            format: { with: /\A([^@\s]+)@(([-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :tel,
            allow_blank: true,
            format: { with: /\A0[0-9]{1,3}-[0-9]{1,4}-[0-9]{1,4}\z/ }
  validates :zip,
            allow_blank: true,
            format: { with: /\A[0-9]{3}-[0-9]{4}\z/ }
end
