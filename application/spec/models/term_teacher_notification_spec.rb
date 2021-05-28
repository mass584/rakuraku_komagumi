require 'rails_helper'

RSpec.describe TermTeacherNotification, type: :model do
  describe 'メール送信イベントの作成' do
    before :each do
      @term_teacher = FactoryBot.create(:term_teacher)
    end

    context 'メール送信イベントの作成時' do
      it 'メールが送信され、レコードが追加される' do
        Timecop.freeze(Time.zone.now)
        expect(@term_teacher.term_teacher_notifications.count).to eq(0)
        @term_teacher.send_schedule_notification_email
        expect(@term_teacher.term_teacher_notifications.count).to eq(1)
        expect(ApplicationMailer.deliveries.count).to eq(1)
        expect(I18n.l(@term_teacher.term_teacher_notifications.first.created_at, format: :full)).to eq(I18n.l(Time.zone.now, format: :full))
        Timecop.return
      end

      it 'メールアドレス未登録の場合、メールは送信されず、レコードも追加されない' do
        @term_teacher.teacher.update(email: '')
        record = @term_teacher.send_schedule_notification_email
        expect(record.persisted?).to eq(false)
        expect(record.errors.full_messages).to eq(
          [
            "#{@term_teacher.teacher.name}さん：メールアドレスが入力されていません"
          ],
        )
        expect(@term_teacher.term_teacher_notifications.count).to eq(0)
        expect(ApplicationMailer.deliveries.count).to eq(0)
      end
    end
  end
end
