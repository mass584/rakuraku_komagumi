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
            format: { with: /\A[\p{Hiragana}ー]+\z/ }
  validates :gender,
            presence: true
  validates :birth_year,
            presence: true
  validates :email,
            allow_blank: true,
            format: { with: /\A([^@\s]+)@(([-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :tel,
            allow_blank: true,
            format: { with: /\A0[0-9]{1,3}-[0-9]{1,4}-[0-9]{1,4}\z/ }
  validates :zip,
            allow_blank: true,
            format: { with: /\A[0-9]{3}-[0-9]{4}\z/ }
  validates :is_deleted,
            presence: true
  validates :room_id,
            presence: true
  enum gender: { male: 0, female: 1 }

  def grade_at(year)
    full_age = year - birth_year
    case
    when full_age =< 6
      '未'
    when full_age == 7
      '小1'
    when full_age == 8
      '小2'
    when full_age == 9
      '小3'
    when full_age == 10
      '小4'
    when full_age == 11
      '小5'
    when full_age == 12
      '小6'
    when full_age == 13
      '中1'
    when full_age == 14
      '中2'
    when full_age == 15
      '中3'
    when full_age == 16
      '高1'
    when full_age == 17
      '高2'
    when full_age == 18
      '高3'
    else
      '満'
    end
  end

  def name_with_grade(year)
    "#{grade_at(year)} #{name}"
  end
end
