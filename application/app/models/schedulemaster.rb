class Schedulemaster < ApplicationRecord
  belongs_to :room
  has_many :classnumbers, dependent: :destroy
  has_many :student_schedulemaster_mappings, dependent: :destroy
  has_many :students, through: :student_schedulemaster_mappings
  has_many :studentrequests, dependent: :destroy
  has_many :studentrequestmasters, dependent: :destroy
  has_many :subject_schedulemaster_mappings, dependent: :destroy
  has_many :subjects, through: :subject_schedulemaster_mappings
  has_many :schedules, dependent: :destroy
  has_many :teacher_schedulemaster_mappings, dependent: :destroy
  has_many :teachers, through: :teacher_schedulemaster_mappings
  has_many :teacherrequests, dependent: :destroy
  has_many :teacherrequestmasters, dependent: :destroy
  has_many :timetables, dependent: :destroy
  has_many :timetablemasters, dependent: :destroy
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
  validate :verify_batch_status_transition
  validate :verify_context
  after_create :create_associations
  after_update :after_update_batch_status
  enum type: { one_week: 0, variable: 1 }
  enum batch_status: { idle: 0, submitted: 1, running: 2, error: 9 }
  self.inheritance_column = :_type_disabled

  def date_array
    if one_week?
      (('2001-01-01'.to_date)..('2001-01-07'.to_date)).map(&:to_s)
    elsif variable?
      (begin_at..end_at).map(&:to_s)
    end
  end

  def period_array
    (1..max_period).map(&:to_s)
  end

  def seat_array
    (1..max_seat).map(&:to_s)
  end

  def seat_per_teacher_array
    (1..class_per_teacher).map(&:to_s)
  end

  def max_week
    (end_at - begin_at + 7).to_i / 7
  end

  def date_array_one_week(week_number)
    if one_week?
      ('2001-01-01'.to_date)..('2001-01-07'.to_date)
    elsif variable?
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

  def show_type
    if one_week?
      '１週間モード'
    elsif variable?
      '任意期間モード'
    end
  end

  def ordered_students
    students.order(birth_year: 'ASC')
  end

  def ordered_teachers
    teachers.order(name: 'DESC')
  end

  def ordered_subjects
    subjects.order(order: 'ASC')
  end

  def schedules_per_teacher(date, period)
    timetable_id = Timetable.find_by(date: date, period: period).id
    schedules.where(timetable_id: timetable_id).reduce({}) do |accu, schedule|
      (accu[schedule.teacher_id.to_s] ||= []).push(schedule)
    end
  end

  private

  def verify_batch_status_transition
    case batch_status_was
    when nil then
      valid = true
    when 'idle' then
      valid = %w[
        idle
        submitted
      ].include?(status)
    when 'submitted' then
      valid = %w[
        idle
        submitted
        running
      ].include?(status)
    when 'running' then
      valid = %w[
        idle
        submitted
        running
        error
      ].include?(status)
    when 'error' then
      valid = %w[
        idle
        error
      ].include?(status)
    else
      valid = false
    end
    if !valid
      errors[:base] << '現在の状態から指定された状態には遷移できません'
    end
  end

  def verify_context
    return if begin_at.nil? || end_at.nil?

    if variable? && (end_at - begin_at).negative?
      errors[:base] << '開始日、終了日を正しく設定してください。'
    elsif variable? && (end_at - begin_at) >= 50
      errors[:base] << '期間は50日以内に設定してください。'
    end
  end

  def create_associations
    SubjectSchedulemasterMapping.bulk_create(self)
    StudentSchedulemasterMapping.bulk_create(self)
    TeacherSchedulemasterMapping.bulk_create(self)
    Timetablemaster.bulk_create(self)
    Timetable.bulk_create(self)
    Classnumber.bulk_create(self)
    Teacherrequestmaster.bulk_create(self)
    Studentrequestmaster.bulk_create(self)
  end

  def after_update_batch_status
    return if batch_status_changed?
    if new_status == 'submitted'
      submit_optimization_job
    end
  end

  def submit_optimization_job
    if ENV['OPTIMIZATION_QUEUE_TYPE'] == 'AWS_BATCH'
      AwsFunction::Batch.submit_optimization_job(job_name, id)
    elsif ENV['OPTIMIZATION_QUEUE_TYPE'] == 'ACTIVE_JOB'
      OptimizationJob.set(queue: job_name).perform_later(job_name, id)
    else
      OptimizationJob.set(queue: job_name).perform_later(job_name, id)
    end
  end
end
