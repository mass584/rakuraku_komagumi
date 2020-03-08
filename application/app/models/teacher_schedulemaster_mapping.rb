class TeacherSchedulemasterMapping < ApplicationRecord
  belongs_to :teacher
  belongs_to :schedulemaster
  validates :teacher_id,
            presence: true,
            uniqueness: { scope: :schedulemaster_id }
  validates :schedulemaster_id,
            presence: true

  def self.bulk_create(schedulemaster)
    schedulemaster.room.exist_teachers.each do |teacher|
      create(
        schedulemaster_id: schedulemaster.id,
        teacher_id: teacher.id,
      )
    end
  end

  def self.additional_create(teacher, schedulemaster)
    TeacherSchedulemasterMapping.new(
      schedulemaster_id: schedulemaster.id,
      teacher_id: teacher.id,
    ).save && Teacherrequestmaster.new(
      teacher_id: teacher.id,
      schedulemaster_id: schedulemaster.id,
      status: 0,
    ).save
  end
end
