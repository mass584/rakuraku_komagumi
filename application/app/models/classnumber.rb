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

  def self.get_classnumbers(schedulemaster)
    classnumbers = Hash.new { |h, k| h[k] = {} }
    schedulemaster.students.each do |st|
      schedulemaster.subjects.each do |su|
        classnumbers[st.id][su.id] = find_by(
          schedulemaster_id: schedulemaster.id,
          student_id: st.id,
          subject_id: su.id,
        )
      end
    end
    classnumbers
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
    Classnumber.create(
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
end
