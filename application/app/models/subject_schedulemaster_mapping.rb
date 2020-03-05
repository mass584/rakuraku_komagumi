class SubjectSchedulemasterMapping < ApplicationRecord
  belongs_to :subject
  belongs_to :schedulemaster
  validates :subject_id,
            presence: true,
            uniqueness: { scope: :schedulemaster_id }
  validates :schedulemaster_id,
            presence: true

  def self.bulk_create(room, schedulemaster)
    room.exist_subjects.each do |subject|
      create(
        schedulemaster_id: schedulemaster.id,
        subject_id: subject.id,
      )
    end
  end
end
