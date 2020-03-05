class Studentrequestmaster < ApplicationRecord
  belongs_to :schedulemaster
  belongs_to :student
  validates :schedulemaster_id,
            uniqueness: { scope: [:student_id] }
  validates :status,
            presence: true

  def self.get_studentrequestmasters(schedulemaster)
    studentrequestmasters = {}
    schedulemaster.students.each do |s|
      studentrequestmasters[s.id] = find_by(
        schedulemaster_id: schedulemaster.id,
        student_id: s.id,
      )
    end
    studentrequestmasters
  end

  def self.bulk_create(schedulemaster)
    schedulemaster.students.each do |s|
      create(
        schedulemaster_id: schedulemaster.id,
        student_id: s.id,
        status: 0,
      )
    end
  end
end
