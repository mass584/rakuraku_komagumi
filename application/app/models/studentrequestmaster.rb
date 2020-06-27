class Studentrequestmaster < ApplicationRecord
  belongs_to :schedulemaster
  belongs_to :student
  validates :schedulemaster_id,
            presence: true,
            uniqueness: { scope: [:student_id] }
  validates :student_id,
            presence: true
  validates :status,
            presence: true

  def self.get_studentrequestmasters(schedulemaster)
    schedulemaster.students.reduce({}) do |accu, s|
      accu.merge({
        "#{s.id}" => find_by(
          schedulemaster_id: schedulemaster.id,
          student_id: s.id
        )
      })
    end
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
