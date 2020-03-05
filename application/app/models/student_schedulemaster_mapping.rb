class StudentSchedulemasterMapping < ApplicationRecord
  belongs_to :student
  belongs_to :schedulemaster
  validates :student_id,
            uniqueness: { scope: :schedulemaster_id }

  def self.bulk_create(room, schedulemaster)
    room.exist_students.each do |student|
      create(
        schedulemaster_id: schedulemaster.id,
        student_id: student.id,
        grade: student.grade,
      )
    end
  end
end
