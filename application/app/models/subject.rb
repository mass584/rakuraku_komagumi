class Subject < ApplicationRecord
  include RankedModel
  ranks :row_order
  has_many :student_subject_mappings, dependent: :destroy
  has_many :students, through: :student_subject_mappings
  has_many :teacher_subject_mappings, dependent: :destroy
  has_many :teachers, through: :teacher_subject_mappings
  has_many :subject_schedulemaster_mappings, dependent: :restrict_with_exception
  has_many :schedulemasters, through: :subject_schedulemaster_mappings
  has_many :classnumbers, dependent: :destroy
  has_many :schedules, dependent: :destroy
  validates :name,
            presence: true
  validates :classtype,
            presence: true
  validates :row_order,
            presence: true

  def self.individual(room_id)
    rank(:row_order).where(room_id: room_id, classtype: '個別授業')
  end

  def self.group(room_id)
    rank(:row_order).where(room_id: room_id, classtype: '集団授業')
  end
end
