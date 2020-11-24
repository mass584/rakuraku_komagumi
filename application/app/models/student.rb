class Student < ApplicationRecord
  belongs_to :room
  has_many :student_subjects, dependent: :destroy
  has_many :subjects, through: :student_subjects
  has_many :student_terms, dependent: :restrict_with_exception
  has_many :terms, through: :student_terms

  validates :name_kana,
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
  validates :birth_year,
            presence: true
  validates :gender,
            presence: true
  validate :verify_maximum, on: :create
  enum gender: { male: 0, female: 1 }

  scope :active, -> { where(is_deleted: false) }
  scope :sorted, -> { order(birth_year: 'ASC', name: 'ASC') }

  def birth_year_for(year, grade)
    if grade == 'e1'
      year - 7
    elsif grade == 'e2'
      year - 8
    elsif grade == 'e3'
      year - 9
    elsif grade == 'e4'
      year - 10 
    elsif grade == 'e5'
      year - 11
    elsif grade == 'e6'
      year - 12
    elsif grade == 'j1'
      year - 13
    elsif grade == 'j2'
      year - 14
    elsif grade == 'j3'
      year - 15
    elsif grade == 'h1'
      year - 16
    elsif grade == 'h2'
      year - 17
    elsif grade == 'h3'
      year - 18
    else
      year - 19
    end
  end

  def grade_at(year)
    full_age = year - birth_year
    if full_age <= 6
      '未就'
    elsif full_age == 7
      '小1'
    elsif full_age == 8
      '小2'
    elsif full_age == 9
      '小3'
    elsif full_age == 10
      '小4'
    elsif full_age == 11
      '小5'
    elsif full_age == 12
      '小6'
    elsif full_age == 13
      '中1'
    elsif full_age == 14
      '中2'
    elsif full_age == 15
      '中3'
    elsif full_age == 16
      '高1'
    elsif full_age == 17
      '高2'
    elsif full_age == 18
      '高3'
    else
      '高卒'
    end
  end

  def name_with_grade(year)
    "#{grade_at(year)} #{name}"
  end

  def birth_year_select
    this_year = (Time.zone.now.to_date << 3).year
    {
      '小1': birth_year_for(this_year, 'e1'),
      '小2': birth_year_for(this_year, 'e2'),
      '小3': birth_year_for(this_year, 'e3'),
      '小4': birth_year_for(this_year, 'e4'),
      '小5': birth_year_for(this_year, 'e5'),
      '小6': birth_year_for(this_year, 'e6'),
      '中1': birth_year_for(this_year, 'j1'),
      '中2': birth_year_for(this_year, 'j2'),
      '中3': birth_year_for(this_year, 'j3'),
      '高1': birth_year_for(this_year, 'h1'),
      '高2': birth_year_for(this_year, 'h2'),
      '高3': birth_year_for(this_year, 'h3'),
    }
  end

  private

  def verify_maximum
    if Student.where(room_id: room.id, is_deleted: false).count >= 60
      errors[:base] << '登録可能な上限数を超えています。'
    end
  end
end
