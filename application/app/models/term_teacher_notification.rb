class TermTeacherNotification < ApplicationRecord
  belongs_to :term
  belongs_to :term_teacher

  after_commit :send_schedule_notification_email, on: :create

  validate :notifiable?

  scope :latest, -> { order(created_at: :desc).first }

  private

  def notifiable?
    if term_teacher.teacher.email.blank?
      errors.add(:base, "#{term_teacher.teacher.name}さん：メールアドレスが入力されていません")
    end
  end

  def send_schedule_notification_email
    TeacherMailer.schedule_notifications(term: term, teacher: term_teacher.teacher,
                                         pdf: term_teacher.schedule_pdf).deliver_now
  end
end
