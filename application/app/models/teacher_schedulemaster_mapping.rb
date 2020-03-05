class TeacherSchedulemasterMapping < ApplicationRecord
  belongs_to :teacher
  belongs_to :schedulemaster
  validates :teacher_id,
            presence: true,
            uniqueness: { scope: :schedulemaster_id }
  validates :schedulemaster_id,
            presence: true

  def self.bulk_create(room, schedulemaster)
    room.exist_teachers.each do |teacher|
      create(
        schedulemaster_id: schedulemaster.id,
        teacher_id: teacher.id,
      )
    end
  end
end
