class TeacherSchedulemasterMapping < ApplicationRecord
  belongs_to :teacher
  belongs_to :schedulemaster
  validates :teacher_id,
            uniqueness: { scope: :schedulemaster_id }

  def self.bulk_create(room, schedulemaster)
    room.exist_teachers.each do |teacher|
      create(
        schedulemaster_id: schedulemaster.id,
        teacher_id: teacher.id,
      )
    end
  end
end
