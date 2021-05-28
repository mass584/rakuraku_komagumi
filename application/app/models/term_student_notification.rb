class TermStudentNotification < ApplicationRecord
  belongs_to :term
  belongs_to :term_student
  has_one_attached :schedule_pdf

  validate :notifiable?, on: :create
  validate :attached?, on: :create

  before_validation :attach_schedule_pdf, on: :create
  after_commit :send_schedule_notification_email, on: :create

  scope :latest, -> { order(created_at: :desc).first }

  def schedule_pdf_url
    rails_blob_path(schedule_pdf, only_path: true) if schedule_pdf.present?
  end

  private

  def attach_schedule_pdf
    file = {
      io: StringIO.new(term_student.schedule_pdf),
      filename: "#{term.room.name}_#{term.year}年度_#{term.name}_#{term_student.student.name}様予定表.pdf",
    }
    schedule_pdf.attach(file)
  end

  def notifiable?
    if term_student.student.email.blank?
      errors.add(:base, "#{term_student.student.name}様：メールアドレスが入力されていません")
    end
  end

  def attached?
    unless schedule_pdf.present?
      errors.add(:base, 'ファイルが添付されていません')
    end
  end

  def send_schedule_notification_email
    StudentMailer.schedule_notifications(term: term, student: term_student.student,
                                         pdf: term_student.schedule_pdf).deliver_now
  end
end
