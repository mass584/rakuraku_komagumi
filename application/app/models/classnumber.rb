class Classnumber < ApplicationRecord
  belongs_to :schedulemaster
  belongs_to :student
  belongs_to :teacher, optional: true
  belongs_to :subject
  validates :schedulemaster_id,
            presence: true
  validates :student_id,
            presence: true,
            uniqueness: { scope: [:subject_id, :schedulemaster_id] }
  validates :subject_id,
            presence: true
  validates :number,
            presence: true
  validate :update_teacher_id_ok?, on: :update, if: :teacher_id_changed?
  validate :update_number_ok?, on: :update, if: :number_changed?
  before_update :before_update_teacher_id, if: :teacher_id_changed?
  before_update :before_update_number, if: :number_changed?

  def self.get_classnumbers(schedulemaster)
    schedulemaster.students.reduce({}) do |accu_st, st|
      accu_st.merge(
        "#{st.id}" => schedulemaster.subjects.reduce({}) do |accu_su, su|
          accu_su.merge(
            "#{su.id}" => find_by(
              schedulemaster_id: schedulemaster.id,
              student_id: st.id,
              subject_id: su.id
            )
          )
        end
      )
    end
  end

  def self.bulk_create(schedulemaster)
    schedulemaster.students.each do |st|
      schedulemaster.subjects.each do |su|
        create_with_schedule(st, su, schedulemaster)
      end
    end
  end

  def self.bulk_create_for_student(student, schedulemaster)
    schedulemaster.subjects.each do |su|
      create_with_schedule(student, su, schedulemaster)
    end
  end

  def self.bulk_create_for_subject(subject, schedulemaster)
    schedulemaster.students.each do |st|
      create_with_schedule(st, subject, schedulemaster)
    end
  end

  def self.create_with_schedule(student, subject, schedulemaster)
    number = student.subjects.exists?(id: subject.id) ? 1 : 0
    self.create(
      schedulemaster_id: schedulemaster.id,
      student_id: student.id,
      subject_id: subject.id,
      teacher_id: nil,
      number: number,
    )
    return if number.zero?
    Schedule.create(
      schedulemaster_id: schedulemaster.id,
      student_id: student.id,
      subject_id: subject.id,
      teacher_id: nil,
      timetable_id: nil,
      status: 0,
    )
  end

  private

  def update_teacher_id_ok?
    assigned_schedules = schedulemaster.schedules.where(
      student_id: student_id,
      subject_id: subject_id,
    ).where.not(
      timetable_id: nil
    )
    if assigned_schedules.count.positive?
      errors[:base] << '予定が決定済の授業があるため、担任の先生を変更することが出来ません。
        変更したい場合は、この画面で該当する授業を削除し、再設定を行ってください。'
    end
  end

  def update_number_ok?
    deletable_schedules = schedulemaster.schedules.where(
      student_id: student_id,
      subject_id: subject_id,
      timetable_id: nil
    )
    if number_was > number && (number_was - number) > deletable_schedules.count
      errors[:base] << '授業回数を、予定決定済の授業数よりも少なくすることは出来ません。
        少なくしたい場合は、全体予定編集画面で決定済の授業を未決定に戻してください。'
    end
  end

  def before_update_teacher_id
    schedulemaster.schedules.where(
      student_id: student_id,
      subject_id: subject_id,
    ).update_all(
      teacher_id: teacher_id
    )
  end

  def before_update_number
    if number > number_was
      (number - number_was).times do
        Schedule.create(
          schedulemaster_id: schedulemaster_id,
          student_id: student_id,
          teacher_id: teacher_id,
          subject_id: subject_id,
          timetable_id: nil,
          status: 0,
        )
      end
    elsif number < number_was
      (number_was - number).times do
        schedulemaster.schedules.find_by(
          student_id: student_id,
          subject_id: subject_id,
          timetable_id: nil
        ).destroy
      end
    end
  end
end
