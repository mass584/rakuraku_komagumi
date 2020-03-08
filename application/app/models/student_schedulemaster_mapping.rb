class StudentSchedulemasterMapping < ApplicationRecord
  belongs_to :student
  belongs_to :schedulemaster
  validates :student_id,
            presence: true,
            uniqueness: { scope: :schedulemaster_id }
  validates :schedulemaster_id,
            presence: true

  def self.bulk_create(schedulemaster)
    schedulemaster.room.exist_students.each do |student|
      create(
        schedulemaster_id: schedulemaster.id,
        student_id: student.id
      )
    end
  end

  def self.additional_create(student, schedulemaster)
    new(
      schedulemaster_id: schedulemaster.id,
      student_id: student.id,
    ).save && Studentrequestmaster.new(
      schedulemaster_id: schedulemaster.id,
      student_id: student.id,
      status: 0,
    ).save && Classnumber.bulk_create_each_student(
      student,
      schedulemaster
    )
  end
end
