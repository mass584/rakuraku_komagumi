class Teacher < ApplicationRecord
  belongs_to :room
  has_many :teacher_subject_mappings, dependent: :destroy
  has_many :subjects, through: :teacher_subject_mappings
  has_many :teacher_schedulemaster_mappings, dependent: :restrict_with_exception
  has_many :schedulemasters, through: :teacher_schedulemaster_mappings
  has_many :teacherrequests, dependent: :destroy
  has_many :teacherrequestmasters, dependent: :destroy
  has_many :classnumbers, dependent: :destroy
  has_many :schedules, dependent: :destroy
  validates :lastname,
            presence: true
  validates :firstname,
            presence: true
  validates :lastname_kana,
            presence: true,
            format: { with: /\A[\p{Hiragana}ー]+\z/, allow_blank: true }
  validates :firstname_kana,
            presence: true,
            format: { with: /\A[\p{Hiragana}ー]+\z/, allow_blank: true }
  validates :zip,
            length: { is: 8, allow_blank: true },
            format: { with: /\A[0-9]{3}-[0-9]{4}\z/, allow_blank: true }
  validates :tel,
            length: { maximum: 16 },
            format: { with: /\A0[0-9]{1,3}-[0-9]{1,4}-[0-9]{1,4}\z/, allow_blank: true }
  validates :room_id,
            presence: true

  def fullname
    lastname + firstname
  end

  def fullname_kana
    lastname_kana + firstname_kana
  end
end
