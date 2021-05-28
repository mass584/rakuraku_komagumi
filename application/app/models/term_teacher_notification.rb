class TermTeacherNotification < ApplicationRecord
  belongs_to :term
  belongs_to :term_teacher
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
      io: StringIO.new(term_teacher.schedule_pdf),
      filename: "#{term.room.name}_#{term.year}年度_#{term.name}_#{term_teacher.teacher.name}さん予定表.pdf",
    }
    schedule_pdf.attach(file)
  end

  def notifiable?
    if term_teacher.teacher.email.blank?
      errors.add(:base, "#{term_teacher.teacher.name}さん：メールアドレスが入力されていません")
    end
  end

  def attached?
    unless schedule_pdf.present?
      errors.add(:base, 'ファイルが添付されていません')
    end
  end

  def send_schedule_notification_email
    TeacherMailer.schedule_notifications(term: term, teacher: term_teacher.teacher,
                                         pdf: term_teacher.schedule_pdf).deliver_now
  end
end
