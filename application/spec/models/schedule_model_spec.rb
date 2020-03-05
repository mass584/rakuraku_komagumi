require 'rails_helper'

RSpec.describe Schedule, type: :model do
  describe 'timetable#update' do
    before :each do
      @room = FactoryBot.create(:room)
      @schedulemaster = FactoryBot.create(:schedulemaster)
      @subject = FactoryBot.create(:subject)
      @teacher = FactoryBot.create(:teacher)
      @student1 = FactoryBot.create(:student, id: 1, firstname: 'firstname1')
      @student2 = FactoryBot.create(:student, id: 2, firstname: 'firstname2')
      @student3 = FactoryBot.create(:student, id: 3, firstname: 'firstname3')
      @timetable1 = FactoryBot.create(:timetable, id: 1, classnumber: 1)
      @timetable2 = FactoryBot.create(:timetable, id: 2, classnumber: 2)
    end

    context 'when one schedule record that have any schedulemaster_id, timetable_id and teacher_id is exist,' do
      it 'should pass to create the new schedule that have previout values.' do
        FactoryBot.create(:schedule, id: 1, student_id: 1)
        expect(FactoryBot.create(:schedule, id: 2, student_id: 2)).to be_valid
      end
    end

    context 'when two schedule records that have same schedulemaster_id, timetable_id and teacher_id are exist,' do
      it 'should fail to create the new schedule that have previout values.' do
        FactoryBot.create(:schedule, id: 1, student_id: 1)
        FactoryBot.create(:schedule, id: 2, student_id: 2)
        expect { FactoryBot.create(:schedule, id: 3, student_id: 3) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when one schedule record that have any schedulemaster_id, timetable_id and teacher_id is exist,' do
      it 'should pass to update to the schedule that have previout values.' do
        FactoryBot.create(:schedule, id: 1, student_id: 1, timetable_id: 1)
        schedule = FactoryBot.create(:schedule, id: 2, student_id: 2, timetable_id: 2)
        schedule.timetable_id = 1
        expect(schedule).to be_valid
      end
    end

    context 'when two schedule records that have any schedulemaster_id, timetable_id and teacher_id are exist,' do
      it 'should fail to update to the schedule that have previout values.' do
        FactoryBot.create(:schedule, id: 1, student_id: 1, timetable_id: 1)
        FactoryBot.create(:schedule, id: 2, student_id: 2, timetable_id: 1)
        schedule = FactoryBot.create(:schedule, id: 3, student_id: 3, timetable_id: 2)
        schedule.timetable_id = 1
        expect(schedule).to be_invalid
      end
    end
  end
end
