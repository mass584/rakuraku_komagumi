require 'rails_helper'

RSpec.describe StudentrequestController, type: :controller do
  before :each do
    allow(controller).to receive(:check_logined).and_return(true)
    FactoryBot.create(:room)
    @teacher = FactoryBot.create(:teacher)
    FactoryBot.create(:student)
    FactoryBot.create(:subject)
    FactoryBot.create(:schedulemaster, totalclassnumber: 4, schedule_type: '講習時期', enddate: '2019-01-01')
    FactoryBot.create(:calculation_rule, eval_target: 'student')
    FactoryBot.create(:student_schedulemaster_mapping)
    FactoryBot.create(:teacherrequestmaster)
    FactoryBot.create(:studentrequestmaster)
    FactoryBot.create(:timetable, id: 1, scheduledate: '2019-01-01', classnumber: 1)
    FactoryBot.create(:timetable, id: 2, scheduledate: '2019-01-01', classnumber: 2)
    FactoryBot.create(:timetable, id: 3, scheduledate: '2019-01-01', classnumber: 3)
    FactoryBot.create(:timetable, id: 4, scheduledate: '2019-01-01', classnumber: 4)
    FactoryBot.create(:classnumber, number: 1)
  end

  describe 'studentrequest#create' do
    context 'when studentrequest is not exist,' do
      it 'should success to create.' do
        post :create,
             params: { scheduledate: '2019-01-01', classnumber: 1, student_id: 1 },
             session: { schedulemaster_id: 1 },
             format: :json
        expect(response.status).to eq(204)
        expect(Studentrequest.all.count).to eq(1)
      end
    end
  end

  describe 'studentrequest#bulk_create' do
    context 'when studentrequests is not exist,' do
      it 'should success to create.' do
        post :bulk_create,
             params: { scheduledate: '2019-01-01', student_id: 1 },
             session: { schedulemaster_id: 1 },
             format: :json
        expect(response.status).to eq(204)
        expect(Studentrequest.all.count).to eq(4)
      end
    end
  end

  describe 'studentrequest#delete' do
    context 'when studentrequest is exist,' do
      it 'should success to destroy.' do
        FactoryBot.create(:studentrequest)
        delete :delete,
               params: { id: 1, scheduledate: '2019-01-01', classnumber: 1, student_id: 1 },
               session: { schedulemaster_id: 1 },
               format: :json
        expect(response.status).to eq(204)
        expect(Studentrequest.all.count).to eq(0)
      end
    end

    context 'when studentrequest is exist and it has child schedule,' do
      it 'should fail to delete.' do
        FactoryBot.create(:schedule)
        FactoryBot.create(:studentrequest)
        delete :delete,
               params: { scheduledate: '2019-01-01', classnumber: 1, student_id: 1 },
               session: { schedulemaster_id: 1 },
               format: :json
        expect(response.status).to eq(400)
        expect(Studentrequest.all.count).to eq(1)
      end
    end
  end

  describe 'studentrequest#bulk_delete' do
    context 'when studentrequest is exist,' do
      it 'should success to bulk_delete.' do
        FactoryBot.create(:studentrequest)
        delete :bulk_delete,
               params: { scheduledate: '2019-01-01', student_id: 1 },
               session: { schedulemaster_id: 1 },
               format: :json
        expect(response.status).to eq(200)
        expect(Studentrequest.all.count).to eq(0)
      end
    end

    context 'when studentrequest is exist and it has child schedule,' do
      it 'should success to delete record only that have no child record.' do
        FactoryBot.create(:schedule)
        FactoryBot.create(:studentrequest, id: 1, timetable_id: 1)
        FactoryBot.create(:studentrequest, id: 2, timetable_id: 2)
        delete :bulk_delete,
               params: { scheduledate: '2019-01-01', student_id: 1 },
               session: { schedulemaster_id: 1 },
               format: :json
        json_res = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(json_res['fail_list']).to eq([{ 'scheduledate' => '2019-01-01', 'classnumber' => 1 }])
        expect(Studentrequest.all.count).to eq(1)
      end
    end
  end

  describe 'studentrequest#occupation_and_matching' do
    context 'when studentrequest is matched with teacherrequest and have enough margin (under 75%),' do
      it 'should success to get occupation_and_matching with bad_matching_list.' do
        FactoryBot.create(:teacherrequest, id: 1, timetable_id: 1)
        FactoryBot.create(:teacherrequest, id: 2, timetable_id: 2)
        FactoryBot.create(:teacherrequest, id: 3, timetable_id: 3)
        FactoryBot.create(:teacherrequest, id: 4, timetable_id: 4)
        FactoryBot.create(:studentrequest, id: 1, timetable_id: 1)
        FactoryBot.create(:studentrequest, id: 2, timetable_id: 2)
        FactoryBot.create(:studentrequest, id: 3, timetable_id: 3)
        FactoryBot.create(:studentrequest, id: 4, timetable_id: 4)
        get :occupation_and_matching,
            params: { student_id: 1 },
            session: { schedulemaster_id: 1 },
            format: :json
        json_res = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(json_res['required']).to eq(1)
        expect(json_res['occupation']).to eq(0.25)
        expect(json_res['matching']).to eq([])
      end
    end

    context 'when teacherrequest is matched with studentrequest but only have a little margin,' do
      it 'should success to get occupation_and_matching with bad_matching_list.' do
        FactoryBot.create(:teacherrequest)
        FactoryBot.create(:studentrequest)
        get :occupation_and_matching,
            params: { student_id: 1 },
            session: { schedulemaster_id: 1 },
            format: :json
        json_res = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(json_res['required']).to eq(1)
        expect(json_res['occupation']).to eq(1)
        expect(json_res['matching']).to eq([{
          'teacher_fullname' => @teacher.fullname,
          'required' => 1,
          'matched' => 1,
        }])
      end
    end

    context 'when studentrequest is unmatched with studentrequest,' do
      it 'should success to get occupation_and_matching with bad_matching_list.' do
        FactoryBot.create(:teacherrequest)
        get :occupation_and_matching,
            params: { student_id: 1 },
            session: { schedulemaster_id: 1 },
            format: :json
        json_res = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(json_res['required']).to eq(1)
        expect(json_res['occupation']).to eq(-1)
        expect(json_res['matching']).to eq([{
          'teacher_fullname' => @teacher.fullname,
          'required' => 1,
          'matched' => 0,
        }])
      end
    end
  end
end
