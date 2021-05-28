class StudentMailer < ApplicationMailer
  def schedule_notifications(term:, student:, pdf:)
    subject = "#{term.year}年度#{term.name} スケジュールの通知"
    filename = "#{term.year}年度#{term.name}スケジュール_#{student.name}様.pdf"
    attachments[filename] = pdf.render
    @term = term
    @student = student
    mail(to: student.email, subject: subject, &:html)
  end
end
