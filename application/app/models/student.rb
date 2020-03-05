class Student < ApplicationRecord
  belongs_to :room
  has_many :student_subject_mappings, dependent: :destroy
  has_many :subjects, through: :student_subject_mappings
  has_many :student_schedulemaster_mappings, dependent: :restrict_with_exception
  has_many :schedulemasters, through: :student_schedulemaster_mappings
  has_many :studentrequests, dependent: :restrict_with_exception
  has_many :studentrequestmasters, dependent: :restrict_with_exception
  has_many :classnumbers, dependent: :restrict_with_exception
  has_many :schedules, dependent: :restrict_with_exception
  validates :name,
            presence: true
  validates :name_kana,
            presence: true,
            format: { with: /\A[\p{Hiragana}ー]+\z/, allow_blank: true }
  validates :gender,
            presence: true
  validates :birth_year,
            presence: true
  validates :tel,
            length: { maximum: 16 },
            format: { with: /\A0[0-9]{1,3}-[0-9]{1,4}-[0-9]{1,4}\z/, allow_blank: true }
  validates :zip,
            length: { is: 8, allow_blank: true },
            format: { with: /\A[0-9]{3}-[0-9]{4}\z/, allow_blank: true }
  validates :is_deleted,
            presence: true
  validates :room_id,
            presence: true
  enum gender: { male: 0, female: 1 }

  def grade_at(year)
    full_age = year - birth_year
    case full_age
    when 7
      '小1'
    when 8
      '小2'
    when 9
      '小3'
    when 10
      '小4'
    when 11
      '小5'
    when 12
      '小6'
    when 13
      '中1'
    when 14
      '中2'
    when 15
      '中3'
    when 16
      '高1'
    when 17
      '高2'
    when 18
      '高3'
    else
      ''
    end
  end

  def name_with_grade(schedulemaster)
    "#{grade_when(schedulemaster)} #{fullname}"
  end
end
