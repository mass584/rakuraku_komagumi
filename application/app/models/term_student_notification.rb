class TermStudentNotification < ApplicationRecord
  belongs_to :term
  belongs_to :term_student

  after_commit :send_schedule_notification_email, on: :create

  validate :notifiable?

  scope :latest, -> { order(created_at: :desc).first }

  private

  def notifiable?
    if term_student.student.email.blank?
      errors.add(:base, "#{term_student.student.name}様：メールアドレスが入力されていません")
    end
  end

  def send_schedule_notification_email
    StudentMailer.schedule_notifications(term: term, student: term_student.student,
                                         pdf: term_student.schedule_pdf).deliver_now
  end
end
