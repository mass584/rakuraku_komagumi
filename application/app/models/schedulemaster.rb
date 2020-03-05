class Schedulemaster < ApplicationRecord
  belongs_to :room
  has_many :subject_schedulemaster_mappings, dependent: :destroy
  has_many :subjects, through: :subject_schedulemaster_mappings
  has_many :teacher_schedulemaster_mappings, dependent: :destroy
  has_many :teachers, through: :teacher_schedulemaster_mappings
  has_many :student_schedulemaster_mappings, dependent: :destroy
  has_many :students, through: :student_schedulemaster_mappings
  has_many :studentrequests, dependent: :destroy
  has_many :teacherrequests, dependent: :destroy
  has_many :timetables, dependent: :destroy
  has_many :timetablemasters, dependent: :destroy
  has_many :classnumbers, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :studentrequestmasters, dependent: :destroy
  has_many :teacherrequestmasters, dependent: :destroy
  validates :name,
            presence: true
  validates :type,
            presence: true
  validates :year,
            presence: true
  validates :begin_at,
            presence: true
  validates :end_at,
            presence: true
  validates :max_period,
            presence: true
  validates :max_seat,
            presence: true
  validates :class_per_teacher,
            presence: true
  validates :batch_status,
            presence: true
  validates :room_id,
            presence: true
  validate :verify_context
  enum type: { one_week: 0, free_range: 1 }
  self.inheritance_column = :_type_disabled

  def verify_context
    return if begin_at.nil? || end_at.nil?

    if free_range? && (end_at - begin_at).negative?
      errors[:base] << '開始日、終了日を正しく設定してください。'
    else free_range? && (end_at - begin_at) >= 50
      errors[:base] << '期間は50日以内に設定してください。'
    end
  end

  def period_array
    1..max_period
  end

  def date_array
    if one_week?
      ('2001-01-01'.to_date)..('2001-01-07'.to_date)
    elsif free_range?
      begin_at..end_at
    end
  end

  def max_week
    (end_at - begin_at + 7).to_i / 7
  end

  def date_array_one_week(week_number)
    if one_week?
      ('2001-01-01'.to_date)..('2001-01-07'.to_date)
    elsif free_range?
      week_number = 1 if week_number < 1
      week_number = max_week if week_number > max_week
      begindate = begin_at + (7 * week_number) - 7
      enddate = begin_at + (7 * week_number) - 1
      enddate = self.end_at if enddate > self.end_at
      begindate..enddate
    end
  end

  def readied_teachers
    teachers.joins(:teacherrequestmasters).where(
      'teacherrequestmasters.schedulemaster_id': id,
      'teacherrequestmasters.status': 1,
    )
  end

  def readied_students
    students.joins(:studentrequestmasters).where(
      'studentrequestmasters.schedulemaster_id': id,
      'studentrequestmasters.status': 1,
    )
  end
end
