require 'rails_helper'

RSpec.describe TermTutorial, type: :model do
  describe '個別授業の追加' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(0, 2)
      @tutorial = FactoryBot.create(:tutorial, room: @term.room)
    end

    it '個別授業を新規に追加した場合、TutorialContractが生成される' do
      expect(TermTutorial.all.count).to eq(5)
      expect(TutorialContract.all.count).to eq(10)
      TermTutorial.create(term: @term, tutorial: @tutorial)
      expect(TermTutorial.all.count).to eq(6)
      expect(TutorialContract.all.count).to eq(12)
    end
  end
end
