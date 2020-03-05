require 'rails_helper'

RSpec.describe TimetableController, type: :controller do
  before :each do
    allow(controller).to receive(:check_logined).and_return(true)
    FactoryBot.create(:room)
    FactoryBot.create(:teacher)
    FactoryBot.create(:student)
    FactoryBot.create(:subject)
    FactoryBot.create(:schedulemaster)
    @timetable = FactoryBot.create(:timetable)
    @timetablemaster = FactoryBot.create(:timetablemaster)
  end

  describe 'timetable#update' do
    context "when timetable is exist and doesn't have child schedule," do
      it 'should success to change the status from -1 to 0.' do
        put :update, params: { id: 1, status: -1 }, session: { schedulemaster_id: 1 }, format: :json
        expect(response.status).to eq(204)
        expect(Timetable.find(@timetable.id).status).to eq(-1)
      end
    end

    context 'when timetable is exist and have child schedule,' do
      it 'should fail to change the status from -1 to 0.' do
        FactoryBot.create(:schedule)
        put :update, params: { id: 1, status: -1 }, session: { schedulemaster_id: 1 }, format: :json
        expect(response.status).to eq(400)
        expect(Timetable.find(@timetable.id).status).to eq(0)
      end
    end
  end

  describe 'timetable#update_master' do
    context 'when timetablemaster is exist,' do
      it 'should success to change the begintime and endtime.' do
        put :update_master,
            params: { id: 1, begintime: '12:00:00', endtime: '13:00:00' },
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(204)
        expect(Timetablemaster.find(@timetablemaster.id).begintime).to eq('2000-01-01 12:00:00.000000000 +0000')
        expect(Timetablemaster.find(@timetablemaster.id).endtime).to eq('2000-01-01 13:00:00.000000000 +0000')
      end
    end
  end
end
