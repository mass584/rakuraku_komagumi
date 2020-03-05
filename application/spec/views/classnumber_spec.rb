RSpec.describe 'classnumber', type: :view do
  before :each do
    @room = FactoryBot.create(:room)
    FactoryBot.create(:teacher)
    FactoryBot.create(:student)
    FactoryBot.create(:subject)
    @schedulemaster = FactoryBot.create(:schedulemaster)
  end

  before :each do
    def view.room
      @room
    end

    def view.schedulemaster
      @schedulemaster
    end

    def view.classnumbers
      Classnumber.get_classnumbers(@schedulemaster)
    end
  end

  describe '/classnumber' do
    it 'should success to show.' do
      render template: 'classnumber/index.html.slim'
    end
  end
end
