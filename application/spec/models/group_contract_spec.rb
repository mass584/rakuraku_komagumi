require 'rails_helper'

RSpec.describe GroupContract, type: :model do
  describe '１日のコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 1)
      tutorial_contract_first = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).first
      tutorial_contract_second = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).second
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: term.term_teachers.second.id)

      @group_contract_first = term.group_contracts.where(term_student_id: term.term_students.first.id).first
      @group_contract_second = term.group_contracts.where(term_student_id: term.term_students.first.id).second
      @piece_first = tutorial_contract_first.tutorial_pieces.first
      @piece_second = tutorial_contract_second.tutorial_pieces.first

      @timetable_first = term.timetables.find_by(date_index: 1, period_index: 1)
      @timetable_first.update(term_group_id: @group_contract_first.term_group_id)
      @timetable_second = term.timetables.find_by(date_index: 1, period_index: 2)
      @timetable_second.update(term_group_id: @group_contract_second.term_group_id)
      @timetable_third = term.timetables.find_by(date_index: 1, period_index: 3)
      @timetable_fourth = term.timetables.find_by(date_index: 1, period_index: 4)
      @timetable_fifth = term.timetables.find_by(date_index: 1, period_index: 5)
      @seat_first = @timetable_first.seats.first
      @seat_second = @timetable_second.seats.first
      @seat_third = @timetable_third.seats.first
      @seat_fourth = @timetable_fourth.seats.first
      @seat_fifth = @timetable_fifth.seats.first
    end

    context '契約の新規設定時(is_contracted : false -> true)' do
      it '最大コマ数を越した場合にupdate失敗' do
        expect(@piece_first.update(seat_id: @seat_third.id)).to eq(true)
        expect(@piece_first.reload.seat_id).to eq(@seat_third.id)
        expect(@piece_second.update(seat_id: @seat_fourth.id)).to eq(true)
        expect(@piece_second.reload.seat_id).to eq(@seat_fourth.id)
        expect(@group_contract_first.update(is_contracted: true)).to eq(true)
        expect(@group_contract_first.reload.is_contracted).to eq(true)
        expect(@group_contract_second.update(is_contracted: true)).to eq(false)
        expect(@group_contract_second.reload.is_contracted).to eq(false)
        expect(@group_contract_second.errors.full_messages).to include('生徒の１日の合計コマの上限を超えています')
      end
    end
  end

  describe '１日の空きコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 1)
      tutorial_contract_first = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).first
      tutorial_contract_second = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).second
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: term.term_teachers.second.id)

      @group_contract_first = term.group_contracts.where(term_student_id: term.term_students.first.id).first
      @group_contract_second = term.group_contracts.where(term_student_id: term.term_students.first.id).second
      @piece_first = tutorial_contract_first.tutorial_pieces.first
      @piece_second = tutorial_contract_second.tutorial_pieces.first

      @timetable_first = term.timetables.find_by(date_index: 1, period_index: 1)
      @timetable_first.update(term_group_id: @group_contract_first.term_group_id)
      @timetable_second = term.timetables.find_by(date_index: 1, period_index: 2)
      @timetable_second.update(term_group_id: @group_contract_second.term_group_id)
      @timetable_third = term.timetables.find_by(date_index: 1, period_index: 3)
      @timetable_fourth = term.timetables.find_by(date_index: 1, period_index: 4)
      @timetable_fifth = term.timetables.find_by(date_index: 1, period_index: 5)
      @seat_first = @timetable_first.seats.first
      @seat_second = @timetable_second.seats.first
      @seat_third = @timetable_third.seats.first
      @seat_fourth = @timetable_fourth.seats.first
      @seat_fifth = @timetable_fifth.seats.first
    end

    context '契約の新規設定時(is_contracted : false -> true)' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        expect(@piece_first.update(seat_id: @seat_fifth.id)).to eq(true)
        expect(@piece_first.reload.seat_id).to eq(@seat_fifth.id)
        expect(@group_contract_first.update(is_contracted: true)).to eq(false)
        expect(@group_contract_first.reload.is_contracted).to eq(false)
        expect(@group_contract_first.errors.full_messages).to include('生徒の１日の空きコマの上限を超えています')
      end
    end

    context '契約の解除設定時(is_contracted : true -> false)' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        expect(@group_contract_first.update(is_contracted: true)).to eq(true)
        expect(@group_contract_first.reload.is_contracted).to eq(true)
        expect(@group_contract_second.update(is_contracted: true)).to eq(true)
        expect(@group_contract_second.reload.is_contracted).to eq(true)
        expect(@piece_first.update(seat_id: @seat_fourth.id)).to eq(true)
        expect(@piece_first.reload.seat_id).to eq(@seat_fourth.id)
        expect(@group_contract_second.update(is_contracted: false)).to eq(false)
        expect(@group_contract_second.reload.is_contracted).to eq(true)
        expect(@group_contract_second.errors.full_messages).to include('生徒の１日の空きコマの上限を超えています')
      end
    end
  end
end
