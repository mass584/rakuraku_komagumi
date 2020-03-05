RSpec.describe 'timetable', type: :view do
  before :each do
    @room = FactoryBot.create(:room)
    FactoryBot.create(:teacher)
    FactoryBot.create(:student)
    FactoryBot.create(:subject)
    @schedulemaster = FactoryBot.create(:schedulemaster, schedule_type: '通常時期', totalclassnumber: 2)
    FactoryBot.create(:timetable, id: 1, scheduledate: '2001-01-01', classnumber: 1)
    FactoryBot.create(:timetable, id: 2, scheduledate: '2001-01-01', classnumber: 2)
    FactoryBot.create(:timetable, id: 3, scheduledate: '2001-01-02', classnumber: 1)
    FactoryBot.create(:timetable, id: 4, scheduledate: '2001-01-02', classnumber: 2)
    FactoryBot.create(:timetable, id: 5, scheduledate: '2001-01-03', classnumber: 1)
    FactoryBot.create(:timetable, id: 6, scheduledate: '2001-01-03', classnumber: 2)
    FactoryBot.create(:timetable, id: 7, scheduledate: '2001-01-04', classnumber: 1)
    FactoryBot.create(:timetable, id: 8, scheduledate: '2001-01-04', classnumber: 2)
    FactoryBot.create(:timetable, id: 9, scheduledate: '2001-01-05', classnumber: 1)
    FactoryBot.create(:timetable, id: 10, scheduledate: '2001-01-05', classnumber: 2)
    FactoryBot.create(:timetable, id: 11, scheduledate: '2001-01-06', classnumber: 1)
    FactoryBot.create(:timetable, id: 12, scheduledate: '2001-01-06', classnumber: 2)
    FactoryBot.create(:timetable, id: 13, scheduledate: '2001-01-07', classnumber: 1)
    FactoryBot.create(:timetable, id: 14, scheduledate: '2001-01-07', classnumber: 2)
    FactoryBot.create(:timetablemaster, id: 1, classnumber: 1)
    FactoryBot.create(:timetablemaster, id: 2, classnumber: 2)
  end

  before :each do
    def view.room
      @room
    end

    def view.schedulemaster
      @schedulemaster
    end

    def view.timetablemasters
      Timetablemaster.get_timetablemasters(@schedulemaster)
    end

    def view.timetables
      Timetable.get_timetables(@schedulemaster)
    end
  end

  describe '/timetable' do
    it 'should success to show.' do
      render template: 'timetable/index.html.slim'
    end
  end
end
