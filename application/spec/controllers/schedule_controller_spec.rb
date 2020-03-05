require 'rails_helper'

RSpec.describe ScheduleController, type: :controller do
  before :each do
    allow(controller).to receive(:check_logined).and_return(true)
    FactoryBot.create(:room)
    FactoryBot.create(:teacher, id: 1)
    FactoryBot.create(:teacher, id: 2)
    FactoryBot.create(:student)
    FactoryBot.create(:subject)
    FactoryBot.create(:schedulemaster, totalclassnumber: 4)
    FactoryBot.create(:timetable, id: 1, classnumber: 1)
    FactoryBot.create(:timetable, id: 2, classnumber: 2)
    FactoryBot.create(:timetable, id: 3, classnumber: 3)
    FactoryBot.create(:timetable, id: 4, classnumber: 4)
  end

  describe 'schedule#update' do
    context 'when update schedule record,' do
      it 'should get success response.' do
        FactoryBot.create(:schedule)
        req_body = {
          id: 1,
          timetable_id: 2,
          teacher_id: 2,
          status: 0,
        }
        put :update,
            params: req_body,
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(204)
        expect(Schedule.find(1).timetable_id).to eq(2)
        expect(Schedule.find(1).teacher_id).to eq(2)
        expect(Schedule.find(1).status).to eq(0)
      end
    end
  end

  describe 'schedule#bulk_update' do
    context 'when bulk_update schedule status to 0,' do
      it 'should get success response.' do
        FactoryBot.create(:schedule, id: 1, timetable_id: 1, status: 1)
        FactoryBot.create(:schedule, id: 2, timetable_id: 2, status: 1)
        FactoryBot.create(:schedule, id: 3, timetable_id: 3, status: 1)
        req_body = {
          status: 0,
        }
        put :bulk_update,
            params: req_body,
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(204)
        expect(Schedule.find(1).status).to eq(0)
        expect(Schedule.find(2).status).to eq(0)
        expect(Schedule.find(3).status).to eq(0)
      end
    end

    context 'when bulk_update schedule status to 1,' do
      it 'should get success response.' do
        FactoryBot.create(:schedule, id: 1, timetable_id: 1, status: 0)
        FactoryBot.create(:schedule, id: 2, timetable_id: 2, status: 0)
        FactoryBot.create(:schedule, id: 3, timetable_id: 0, status: 0)
        req_body = {
          status: 1,
        }
        put :bulk_update,
            params: req_body,
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(204)
        expect(Schedule.find(1).status).to eq(1)
        expect(Schedule.find(2).status).to eq(1)
        expect(Schedule.find(3).status).to eq(0)
      end
    end
  end

  describe 'schedule#bulk_reset' do
    context 'when put bulk_reset,' do
      it 'should get success response.' do
        FactoryBot.create(:schedule, id: 1, timetable_id: 1, status: 0)
        FactoryBot.create(:schedule, id: 2, timetable_id: 2, status: 1)
        FactoryBot.create(:schedule, id: 3, timetable_id: 0, status: 0)
        put :bulk_reset,
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(204)
        expect(Schedule.find(1).status).to eq(0)
        expect(Schedule.find(1).timetable_id).to eq(0)
        expect(Schedule.find(2).status).to eq(0)
        expect(Schedule.find(2).timetable_id).to eq(0)
        expect(Schedule.find(3).status).to eq(0)
        expect(Schedule.find(3).timetable_id).to eq(0)
      end
    end
  end
end
