require 'rails_helper'

RSpec.describe SchedulemasterController, type: :controller do
  describe 'schedulemaster#create' do
    before :each do
      allow(controller).to receive(:check_logined).and_return(true)
      FactoryBot.create(:room)
      FactoryBot.create(:teacher, id: 1, is_deleted: false)
      FactoryBot.create(:teacher, id: 2, is_deleted: true)
      FactoryBot.create(:student, id: 1, is_deleted: false)
      FactoryBot.create(:student, id: 2, is_deleted: true)
      FactoryBot.create(:subject, id: 1, row_order: 1, is_deleted: false)
      FactoryBot.create(:subject, id: 2, row_order: 2, is_deleted: true)
    end

    context 'when create schedulemaster record,' do
      it 'should only associate undeleted teacher, students and subjects.' do
        req_body = {
          schedulemaster: {
            schedule_name: 'schedule_name',
            schedule_type: '通常時期',
            begindate: '2019-01-01',
            enddate: '2019-01-31',
            totalclassnumber: 6,
            seatnumber: 6,
            room_id: 1,
          },
        }
        post :create, params: req_body, session: { login_id: 'login_id_1234' }, format: :js
        expect(response.status).to eq(200)
        expect(StudentSchedulemasterMapping.all.count).to eq(1)
        expect(TeacherSchedulemasterMapping.all.count).to eq(1)
        expect(SubjectSchedulemasterMapping.all.count).to eq(1)
      end
    end

    context 'when schedule_type is normal lecture term,' do
      it 'should collectly create child records.' do
        req_body = {
          schedulemaster: {
            schedule_name: 'schedule_name',
            schedule_type: '通常時期',
            begindate: '2019-01-01',
            enddate: '2019-01-31',
            totalclassnumber: 6,
            seatnumber: 6,
            room_id: 1,
          },
        }
        post :create, params: req_body, session: { login_id: 'login_id_1234' }, format: :js
        expect(response.status).to eq(200)
        expect(CalculationRule.all.count).to eq(3)
        expect(Timetablemaster.all.count).to eq(6)
        expect(Timetable.all.count).to eq(42)
        expect(Classnumber.all.count).to eq(1)
        expect(Teacherrequestmaster.all.count).to eq(1)
        expect(Studentrequestmaster.all.count).to eq(1)
      end
    end

    context 'when schedule_type is seasonal lecture term,' do
      it 'should collectly create child records.' do
        req_body = {
          schedulemaster: {
            schedule_name: 'schedule_name',
            schedule_type: '講習時期',
            begindate: '2019-01-01',
            enddate: '2019-01-31',
            totalclassnumber: 6,
            seatnumber: 6,
            room_id: 1,
          },
        }
        post :create, params: req_body, session: { login_id: 'login_id_1234' }, format: :js
        expect(response.status).to eq(200)
        expect(CalculationRule.all.count).to eq(3)
        expect(Timetablemaster.all.count).to eq(6)
        expect(Timetable.all.count).to eq(186)
        expect(Classnumber.all.count).to eq(1)
        expect(Teacherrequestmaster.all.count).to eq(1)
        expect(Studentrequestmaster.all.count).to eq(1)
      end
    end
  end
end
