require 'rails_helper'

RSpec.describe ClassnumberController, type: :controller do
  before :each do
    allow(controller).to receive(:check_logined).and_return(true)
    FactoryBot.create(:room)
    FactoryBot.create(:teacher)
    FactoryBot.create(:student)
    FactoryBot.create(:subject, id: 1, row_order: 1, classtype: '個別授業')
    FactoryBot.create(:subject, id: 2, row_order: 2, classtype: '個別授業')
    FactoryBot.create(:subject, id: 11, row_order: 11, classtype: '集団授業')
    FactoryBot.create(:schedulemaster,
                      totalclassnumber: 4,
                      schedule_type: '講習時期',
                      begindate: '2019-01-01',
                      enddate: '2019-01-01')
    FactoryBot.create(:calculation_rule, id: 1, eval_target: 'teacher')
    FactoryBot.create(:calculation_rule, id: 2, eval_target: 'student')
    FactoryBot.create(:calculation_rule, id: 3, eval_target: 'student3g')
    FactoryBot.create(:timetable, id: 1, classnumber: 1)
    FactoryBot.create(:timetable, id: 2, classnumber: 2)
    FactoryBot.create(:timetable, id: 3, classnumber: 3)
    FactoryBot.create(:timetable, id: 4, classnumber: 4)
  end

  describe 'classnumber#update' do
    context 'when number of individual lesson is increased,' do
      it 'should success to change number.' do
        FactoryBot.create(:classnumber)
        put :update,
            params: { id: 1, teacher_id: 1, number: 4 },
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(204)
        expect(Schedule.all.count).to eq(4)
      end
    end

    context 'when number of individual lesson is decreased, and deletable child record exceed the directed number,' do
      it 'should success to change number.' do
        FactoryBot.create(:classnumber, number: 4)
        FactoryBot.create(:schedule, id: 1, timetable_id: 1)
        FactoryBot.create(:schedule, id: 2, timetable_id: 2)
        FactoryBot.create(:schedule, id: 3, timetable_id: 0)
        FactoryBot.create(:schedule, id: 4, timetable_id: 0)
        put :update,
            params: { id: 1, teacher_id: 1, number: 2 },
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(204)
        expect(Schedule.all.count).to eq(2)
      end
    end

    context "when number of individual lesson is decreased, and deletable child record doesn't exceed the directed number," do
      it 'should fail to change number.' do
        FactoryBot.create(:classnumber, number: 4)
        FactoryBot.create(:schedule, id: 1, timetable_id: 1)
        FactoryBot.create(:schedule, id: 2, timetable_id: 2)
        FactoryBot.create(:schedule, id: 3, timetable_id: 3)
        FactoryBot.create(:schedule, id: 4, timetable_id: 4)
        put :update,
            params: { id: 1, teacher_id: 1, number: 2 },
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(400)
        expect(Schedule.all.count).to eq(4)
      end
    end

    context 'when teacher_id is changed, and the child record already have timetable_id,' do
      it 'should fail to change teacher_id.' do
        FactoryBot.create(:classnumber, number: 4)
        FactoryBot.create(:schedule, id: 1, timetable_id: 1)
        FactoryBot.create(:schedule, id: 2, timetable_id: 2)
        FactoryBot.create(:schedule, id: 3, timetable_id: 3)
        FactoryBot.create(:schedule, id: 4, timetable_id: 4)
        put :update,
            params: { id: 1, teacher_id: 2, number: 4 },
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(400)
        expect(Schedule.all.count).to eq(4)
      end
    end

    context 'when number of group lesson is increased and not violate class rule,' do
      it 'should success to change number.' do
        FactoryBot.create(:classnumber, id: 1, subject_id: 1, number: 1)
        FactoryBot.create(:schedule, id: 1, timetable_id: 1)
        FactoryBot.create(:classnumber, id: 2, subject_id: 11, number: 0)
        Timetable.find(2).update(status: 11)
        put :update,
            params: { id: 2 },
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(204)
        expect(Classnumber.find(2).number).to eq(1)
      end
    end

    context 'when number of group lesson is increased but violate class rule,' do
      it 'should fail to change number.' do
        FactoryBot.create(:classnumber, id: 1, subject_id: 1, number: 1)
        FactoryBot.create(:schedule, id: 1, timetable_id: 1)
        FactoryBot.create(:classnumber, id: 2, subject_id: 11, number: 0)
        Timetable.find(4).update(status: 11)
        put :update,
            params: { id: 2 },
            session: { schedulemaster_id: 1 },
            format: :json
        expect(response.status).to eq(400)
        expect(Classnumber.find(2).number).to eq(0)
      end
    end
  end

  describe 'classnumber#destroy' do
    context 'when delete classnumber of individual and not violate the schedule rule,' do
      it 'should success to delete.' do
        FactoryBot.create(:classnumber, id: 1, subject_id: 1, number: 4)
        FactoryBot.create(:schedule, id: 1, subject_id: 1, timetable_id: 1)
        FactoryBot.create(:schedule, id: 2, subject_id: 1, timetable_id: 2)
        FactoryBot.create(:schedule, id: 3, subject_id: 1, timetable_id: 3)
        FactoryBot.create(:schedule, id: 4, subject_id: 1, timetable_id: 4)
        delete :destroy,
               params: { id: 1 },
               session: { schedulemaster_id: 1 },
               format: :json
        expect(response.status).to eq(204)
        expect(Schedule.all.count).to eq(0)
      end
    end

    context 'when delete classnumber of individual and violate the blank class rule,' do
      it 'should fail to delete.' do
        FactoryBot.create(:classnumber, id: 1, subject_id: 1, number: 1)
        FactoryBot.create(:classnumber, id: 2, subject_id: 2, number: 2)
        FactoryBot.create(:schedule, id: 1, subject_id: 1, timetable_id: 1)
        FactoryBot.create(:schedule, id: 2, subject_id: 2, timetable_id: 2)
        FactoryBot.create(:schedule, id: 3, subject_id: 2, timetable_id: 3)
        FactoryBot.create(:schedule, id: 4, subject_id: 1, timetable_id: 4)
        delete :destroy,
               params: { id: 2 },
               session: { schedulemaster_id: 1 },
               format: :json
        expect(response.status).to eq(400)
        expect(Schedule.all.count).to eq(4)
      end
    end

    context 'when delete classnumber of group and not violate the schedule rule,' do
      it 'should success to delete.' do
        FactoryBot.create(:classnumber, id: 1, subject_id: 1, number: 2)
        FactoryBot.create(:schedule, id: 1, subject_id: 1, timetable_id: 1)
        FactoryBot.create(:schedule, id: 2, subject_id: 1, timetable_id: 2)
        FactoryBot.create(:classnumber, id: 2, subject_id: 11, number: 1)
        Timetable.find(3).update(status: 11)
        delete :destroy,
               params: { id: 2 },
               session: { schedulemaster_id: 1 },
               format: :json
        expect(response.status).to eq(204)
        expect(Classnumber.find(2).number).to eq(0)
      end
    end

    context 'when delete classnumber of group and violate the blank class rule,' do
      it 'should fail to delete.' do
        FactoryBot.create(:classnumber, id: 1, subject_id: 1, number: 2)
        FactoryBot.create(:schedule, id: 1, subject_id: 1, timetable_id: 1)
        FactoryBot.create(:schedule, id: 2, subject_id: 1, timetable_id: 4)
        FactoryBot.create(:classnumber, id: 2, subject_id: 11, number: 1)
        Timetable.find(2).update(status: 11)
        delete :destroy,
               params: { id: 2 },
               session: { schedulemaster_id: 1 },
               format: :json
        expect(response.status).to eq(400)
        expect(Classnumber.find(2).number).to eq(1)
      end
    end
  end
end
