class StudentSchedulemasterMapping < ApplicationRecord
  belongs_to :student
  belongs_to :schedulemaster
  validates :student_id,
            presence: true,
            uniqueness: { scope: :schedulemaster_id }
  validates :schedulemaster_id,
            presence: true

  def self.bulk_create(room, schedulemaster)
    room.exist_students.each do |student|
      create(
        schedulemaster_id: schedulemaster.id,
        student_id: student.id
      )
    end
  end
end
