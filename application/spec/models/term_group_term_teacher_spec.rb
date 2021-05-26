require 'rails_helper'

RSpec.describe TermGroup, type: :model do
  describe '集団授業の追加' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(0, 2)
      @group = FactoryBot.create(:group, room: @term.room)
    end

    it '集団授業を新規に追加した場合、GroupContractが生成される' do
      expect(TermGroup.all.count).to eq(2)
      expect(GroupContract.all.count).to eq(4)
      TermGroup.create(term: @term, group: @group)
      expect(TermGroup.all.count).to eq(3)
      expect(GroupContract.all.count).to eq(6)
    end
  end
end
