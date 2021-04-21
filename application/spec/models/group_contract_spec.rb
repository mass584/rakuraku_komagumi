require 'rails_helper'

RSpec.describe GroupContract, type: :model do
  describe '１日のコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 1)
      timetables = timetables(term)
      seats = seats(term)
      term_student = term.term_students.first
      term_teacher = term.term_teachers.first
      tutorial_contracts = student_tutorial_contracts(term, term_student)
      tutorial_contracts[0].update(piece_count: 1, term_teacher: term_teacher)
      tutorial_contracts[1].update(piece_count: 1, term_teacher: term_teacher)
      tutorial_piece_first = tutorial_contracts[0].tutorial_pieces.first
      tutorial_piece_second = tutorial_contracts[1].tutorial_pieces.first
      @group_contracts = student_group_contracts(term, term_student)
      timetables[0].update(term_group: @group_contracts[0].term_group)
      timetables[1].update(term_group: @group_contracts[1].term_group)
      tutorial_piece_first.update(seat: seats[2])
      tutorial_piece_second.update(seat: seats[3])
    end

    context '契約の新規設定時(is_contracted : false -> true)' do
      it '最大コマ数を越した場合にupdate失敗' do
        expect(@group_contracts[0].update(is_contracted: true)).to eq(true)
        expect(@group_contracts[0].reload.is_contracted).to eq(true)
        expect(@group_contracts[1].update(is_contracted: true)).to eq(false)
        expect(@group_contracts[1].reload.is_contracted).to eq(false)
        expect(@group_contracts[1].errors.full_messages).to include('生徒の１日の合計コマの上限を超えています')
      end
    end
  end

  describe '１日の空きコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 1)
      timetables = timetables(term)
      seats = seats(term)
      term_student = term.term_students.first
      term_teacher_first = term.term_teachers.first
      term_teacher_second = term.term_teachers.second
      tutorial_contracts = student_tutorial_contracts(term, term_student)
      tutorial_contracts[0].update(piece_count: 1, term_teacher: term_teacher_first)
      tutorial_contracts[1].update(piece_count: 1, term_teacher: term_teacher_second)
      @group_contracts = student_group_contracts(term, term_student)
      timetables[0].update(term_group: @group_contracts[0].term_group)
      timetables[1].update(term_group: @group_contracts[1].term_group)
      tutorial_piece_first = tutorial_contracts[0].tutorial_pieces.first
      tutorial_piece_first.update(seat: seats[3])
    end

    context '契約の新規設定時(is_contracted : false -> true)' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        expect(@group_contracts[0].update(is_contracted: true)).to eq(false)
        expect(@group_contracts[0].reload.is_contracted).to eq(false)
        expect(@group_contracts[0].errors.full_messages).to include('生徒の１日の空きコマの上限を超えています')
      end
    end

    context '契約の解除設定時(is_contracted : true -> false)' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        expect(@group_contracts[1].update(is_contracted: true)).to eq(true)
        expect(@group_contracts[1].reload.is_contracted).to eq(true)
        expect(@group_contracts[0].update(is_contracted: true)).to eq(true)
        expect(@group_contracts[0].reload.is_contracted).to eq(true)
        expect(@group_contracts[1].update(is_contracted: false)).to eq(false)
        expect(@group_contracts[1].reload.is_contracted).to eq(true)
        expect(@group_contracts[1].errors.full_messages).to include('生徒の１日の空きコマの上限を超えています')
      end
    end
  end
end
