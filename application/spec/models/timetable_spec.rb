require 'rails_helper'

RSpec.describe Timetable, type: :model do
  describe '休講かどうかの変更' do
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

    context '休講に変更した時' do
      it '個別授業が設定済みの場合updateに失敗する' do
        @piece.update(seat_id: @seat.id)
        expect(@timetable.update(is_closed: true)).to eq(false)
        expect(@timetable.errors.full_messages).to include('個別授業が割り当てられているため変更できません')
      end

      it '集団授業が設定済みの場合updateに失敗する' do
        @timetable.update(term_group_id: @term_group.id)
        expect(@timetable.update(is_closed: true)).to eq(false)
        expect(@timetable.errors.full_messages).to include('集団授業が割り当てられているため変更できません')
      end
    end
  end

  describe '集団授業の変更' do
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

    context '集団授業有りに変更した時' do
      it '個別授業が設定済みの場合updateに失敗する' do
        @piece.update(seat_id: @seat.id)
        expect(@timetable.update(term_group_id: @term_group.id)).to eq(false)
        expect(@timetable.errors.full_messages).to include('個別授業が１つでも割り当てられていると、集団授業の日程を変更することはできません')
      end

      it '休講の場合updateに失敗する' do
        @timetable.update(is_closed: true) 
        expect(@timetable.update(term_group_id: @term_group.id)).to eq(false)
        expect(@timetable.errors.full_messages).to include('休講のため変更できません')
      end
    end
  end
end
