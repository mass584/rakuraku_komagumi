class Student < ApplicationRecord
  belongs_to :room
  has_many :student_subject_mappings, dependent: :destroy
  has_many :subjects, through: :student_subject_mappings
  has_many :student_schedulemaster_mappings, dependent: :restrict_with_exception
  has_many :schedulemasters, through: :student_schedulemaster_mappings
  has_many :studentrequests, dependent: :destroy
  has_many :studentrequestmasters, dependent: :destroy
  has_many :classnumbers, dependent: :destroy
  has_many :schedules, dependent: :destroy
  validates :lastname,
            presence: true
  validates :firstname,
            presence: true
  validates :lastname_kana,
            format: { with: /\A[\p{Hiragana}ー]+\z/, allow_blank: true },
            presence: true
  validates :firstname_kana,
            format: { with: /\A[\p{Hiragana}ー]+\z/, allow_blank: true },
            presence: true
  validates :room_id,
            presence: true
  validates :grade,
            presence: true
  validates :gender,
            presence: true
  validates :zip,
            length: { is: 8, allow_blank: true },
            format: { with: /\A[0-9]{3}-[0-9]{4}\z/, allow_blank: true }
  validates :tel,
            length: { maximum: 16 },
            format: { with: /\A0[0-9]{1,3}-[0-9]{1,4}-[0-9]{1,4}\z/, allow_blank: true }

  def fullname
    lastname + firstname
  end

  def fullname_kana
    lastname_kana + firstname_kana
  end

  def grade_when(schedulemaster)
    student_schedulemaster_mappings.find_by(schedulemaster_id: schedulemaster.id).grade
  end

  def fullname_with_grade(schedulemaster)
    "#{grade_when(schedulemaster)} #{fullname}"
  end
end
