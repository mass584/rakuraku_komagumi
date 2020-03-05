class Schedulemaster < ApplicationRecord
  belongs_to :room
  has_many :calculation_rules, dependent: :destroy
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
  validates :schedule_name,
            presence: true
  validates :schedule_type,
            presence: true
  validates :max_count,
            presence: true
  validates :max_time_sec,
            presence: true
  validates :begindate,
            presence: true
  validates :enddate,
            presence: true
  validates :seatnumber,
            presence: true
  validates :totalclassnumber,
            presence: true
  validates :room_id,
            presence: true
  validate :begin_end_check
  serialize :begintime
  serialize :endtime

  def begin_end_check
    return if begindate.nil? || enddate.nil?

    if schedule_type == '講習時期' && (enddate - begindate).negative?
      errors.add(:enddate, 'の日付を正しく入力してください。')
    elsif schedule_type == '通常時期' && enddate - begindate < 6
      errors.add(:enddate, 'の日付を正しく入力してください。通常時期の場合、期間は一週間以上である必要があります。')
    end
  end

  def class_array
    1..totalclassnumber
  end

  def date_array
    case schedule_type
    when '講習時期' then
      begindate..enddate
    when '通常時期' then
      ('2001-01-01'.to_date)..('2001-01-07'.to_date)
    end
  end

  def date_array_one_week(week_number)
    if week_number < 1
      week_number = 1
    end
    if week_number > max_week
      week_number = max_week
    end
    begindate = self.begindate + (7 * week_number) - 7
    enddate = self.begindate + (7 * week_number) - 1
    if enddate > self.enddate
      enddate = self.enddate
    end
    case schedule_type
    when '講習時期' then
      begindate..enddate
    when '通常時期' then
      ('2001-01-01'.to_date)..('2001-01-07'.to_date)
    end
  end

  def date_count
    (enddate - begindate + 1).to_i
  end

  def max_week
    (enddate - begindate + 7).to_i / 7
  end

  def ordered_students
    grade_index = %w[小6 中1 中2 中3]
    students.sort do |a, b|
      a.firstname_kana <=> b.firstname_kana
    end.sort do |a, b|
      a.lastname_kana <=> b.lastname_kana
    end.sort do |a, b|
      grade_index.find_index(a.grade) <=> grade_index.find_index(b.grade)
    end
  end

  def ordered_subjects
    subjects.order(:row_order)
  end

  def ready_teachers
    teachers.joins(:teacherrequestmasters).where(
      'teacherrequestmasters.schedulemaster_id': id,
      'teacherrequestmasters.status': 1,
    )
  end

  def ready_students
    students.joins(:studentrequestmasters).where(
      'studentrequestmasters.schedulemaster_id': id,
      'studentrequestmasters.status': 1,
    )
  end

  def individual_subjects
    subjects.where(classtype: '個別授業').order(:row_order)
  end

  def group_subjects
    subjects.where(classtype: '集団授業').order(:row_order)
  end
end
