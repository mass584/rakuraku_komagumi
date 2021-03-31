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

  describe '集団授業の担任変更' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 1)
      @term_teacher = term.term_teachers.first
      @term_group = term.term_groups.first
      @tutorial_contract = term.tutorial_contracts.first
      @tutorial_contract.update(piece_count: 1, term_teacher_id: @term_teacher.id)
      @piece = @tutorial_contract.tutorial_pieces.first
      @timetable = term.timetables.first
      @seat = @timetable.seats.first
    end

    it '個別授業が１つも設定されていない場合、updateに成功する' do
      expect(@term_group.update(term_teacher_id: @term_teacher.id)).to eq(true)
      expect(@term_group.reload.term_teacher_id).to eq(@term_teacher.id)
    end

    it '個別授業が少なくとも１つ設定済みの場合updateに失敗する' do
      @piece.update(seat_id: @seat.id)
      expect(@term_group.update(term_teacher_id: @term_teacher.id)).to eq(false)
      expect(@term_group.reload.term_teacher_id).to eq(nil)
      expect(@term_group.errors.full_messages).to include('集団担当を変更するには、個別授業の設定を全て解除する必要があります')
    end
  end
end
