class SubjectSchedulemasterMapping < ApplicationRecord
  belongs_to :subject
  belongs_to :schedulemaster
  validates :subject_id,
            presence: true,
            uniqueness: { scope: :schedulemaster_id }
  validates :schedulemaster_id,
            presence: true

  def self.bulk_create(schedulemaster)
    schedulemaster.room.exist_subjects.each do |subject|
      create(
        schedulemaster_id: schedulemaster.id,
        subject_id: subject.id,
      )
    end
  end

  def self.additional_create(subject, schedulemaster)
    new(
      subject_id: subject.id
      schedulemaster_id: schedulemaster.id
    ).save && Classnumber.bulk_create_each_subject(
      subject,
      schedulemaster
    )
  end
end
