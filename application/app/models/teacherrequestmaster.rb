class Teacherrequestmaster < ApplicationRecord
  belongs_to :schedulemaster
  belongs_to :teacher
  validates :schedulemaster_id,
            presence: true,
            uniqueness: { scope: [:teacher_id] }
  validates :teacher_id,
            presence: true
  validates :status,
            presence: true

  def self.get_teacherrequestmasters(schedulemaster)
    teacherrequestmasters = {}
    schedulemaster.teachers.each do |t|
      teacherrequestmasters[t.id] = find_by(
        schedulemaster_id: schedulemaster.id,
        teacher_id: t.id,
      )
    end
    teacherrequestmasters
  end

  def self.bulk_create(schedulemaster)
    schedulemaster.teachers.each do |t|
      create(
        schedulemaster_id: schedulemaster.id,
        teacher_id: t.id,
        status: 0,
      )
    end
  end
end
