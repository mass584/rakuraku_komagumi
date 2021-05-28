class TeacherMailer < ApplicationMailer
  def schedule_notifications(term:, teacher:, pdf:)
    subject = "#{term.year}年度#{term.name} スケジュールの通知"
    filename = "#{term.year}年度#{term.name}スケジュール_#{teacher.name}さん.pdf"
    attachments[filename] = pdf
    @term = term
    @teacher = teacher
    mail(to: teacher.email, subject: subject, &:html)
  end
end
