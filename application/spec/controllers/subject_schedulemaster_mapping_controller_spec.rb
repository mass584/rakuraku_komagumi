require 'rails_helper'

RSpec.describe SubjectSchedulemasterMappingController, type: :controller do
  before :each do
    allow(controller).to receive(:check_logined).and_return(true)
    FactoryBot.create(:room)
    FactoryBot.create(:teacher)
    FactoryBot.create(:student)
    FactoryBot.create(:subject)
    FactoryBot.create(:schedulemaster, totalclassnumber: 4)
    FactoryBot.create(:subject_schedulemaster_mapping)
    FactoryBot.create(:timetable, id: 1, classnumber: 1)
    FactoryBot.create(:timetable, id: 2, classnumber: 2)
    FactoryBot.create(:timetable, id: 3, classnumber: 3)
    FactoryBot.create(:timetable, id: 4, classnumber: 4)
  end

  describe 'subject_schedulemaster_mapping#update' do
    context "when decided schedule doesn't exist," do
      it 'should success to change teacher_id.' do
        put :update,
            params: { teacher_id: 1, subject_id: 1 },
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(204)
        expect(SubjectSchedulemasterMapping.find(1).teacher_id).to eq(1)
      end
    end

    context 'when decided schedule exist,' do
      it 'should fail to change teacher_id.' do
        FactoryBot.create(:schedule)
        put :update,
            params: { teacher_id: 1, subject_id: 1 },
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(400)
        expect(SubjectSchedulemasterMapping.find(1).teacher_id).to eq(0)
      end
    end
  end
end
