require 'rails_helper'

RSpec.describe TermStudentNotification, type: :model do
  describe 'メール送信イベントの作成' do
    before :each do
      @term_student = FactoryBot.create(:term_student)
    end

    context 'メール送信イベントの作成時' do
      it 'メールが送信され、レコードが追加される' do
        Timecop.freeze(Time.zone.now)
        expect(@term_student.term_student_notifications.count).to eq(0)
        @term_student.send_schedule_notification_email
        expect(@term_student.term_student_notifications.count).to eq(1)
        expect(ApplicationMailer.deliveries.count).to eq(1)
        expect(I18n.l(@term_student.term_student_notifications.first.created_at,
                      format: :full)).to eq(I18n.l(Time.zone.now, format: :full))
        Timecop.return
      end

      it 'メールアドレス未登録の場合、メールは送信されず、レコードも追加されない' do
        @term_student.student.update(email: '')
        record = @term_student.send_schedule_notification_email
        expect(record.persisted?).to eq(false)
        expect(record.errors.full_messages).to eq(
          [
            "#{@term_student.student.name}様：メールアドレスが入力されていません"
          ],
        )
        expect(@term_student.term_student_notifications.count).to eq(0)
        expect(ApplicationMailer.deliveries.count).to eq(0)
      end
    end
  end
end
