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

  describe '１日の合計コマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 1)
      teacher_optimization_rule = term.teacher_optimization_rules.first
      teacher_optimization_rule.update(occupation_limit: 4, serialized_occupation_costs: '18 3 0 6')
      @term_teacher_first = term.term_teachers.first
      @term_teacher_second = term.term_teachers.second
      @term_group_first = term.term_groups.first
      @term_group_second = term.term_groups.second
      timetable_first = term.timetables.find_by(date_index: 1, period_index: 1)
      timetable_second = term.timetables.find_by(date_index: 1, period_index: 2)
      timetable_third = term.timetables.find_by(date_index: 1, period_index: 3)
      timetable_fourth = term.timetables.find_by(date_index: 1, period_index: 4)
      timetable_fourth.update(term_group_id: @term_group_first.id)
      timetable_fifth = term.timetables.find_by(date_index: 1, period_index: 5)
      timetable_fifth.update(term_group_id: @term_group_second.id)
      seat_first = timetable_first.seats.first
      seat_second = timetable_second.seats.first
      seat_third = timetable_third.seats.first
      tutorial_contract_first = term.tutorial_contracts.where(
        term_student_id: term.term_students.first.id,
      ).first
      tutorial_contract_second = term.tutorial_contracts.where(
        term_student_id: term.term_students.first.id,
      ).second
      tutorial_contract_third = term.tutorial_contracts.where(
        term_student_id: term.term_students.first.id,
      ).third
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: @term_teacher_first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: @term_teacher_first.id)
      tutorial_contract_third.update(piece_count: 1, term_teacher_id: @term_teacher_first.id)
      piece_first = tutorial_contract_first.tutorial_pieces.first
      piece_second = tutorial_contract_second.tutorial_pieces.first
      piece_third = tutorial_contract_third.tutorial_pieces.first
      piece_first.update(seat_id: seat_first.id)
      piece_second.update(seat_id: seat_second.id)
      piece_third.update(seat_id: seat_third.id)
    end

    context '担任の追加時' do
      it '最大コマ数を越した場合にupdate失敗' do
        term_group_term_teacher_first = TermGroupTermTeacher.new(
          term_group: @term_group_first,
          term_teacher: @term_teacher_first,
        )
        term_group_term_teacher_second = TermGroupTermTeacher.new(
          term_group: @term_group_second,
          term_teacher: @term_teacher_first,
        )
        expect(term_group_term_teacher_first.save).to eq(true)
        expect(term_group_term_teacher_second.save).to eq(false)
        expect(term_group_term_teacher_second.errors.full_messages).to include('講師の１日の合計コマの上限を超えています')
      end
    end
  end

  describe '１日の空きコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 1)
      @term_teacher_first = term.term_teachers.first
      @term_teacher_second = term.term_teachers.second
      @term_group_first = term.term_groups.first
      @term_group_second = term.term_groups.second
      timetable_first = term.timetables.find_by(date_index: 1, period_index: 1)
      timetable_second = term.timetables.find_by(date_index: 1, period_index: 2)
      timetable_fourth = term.timetables.find_by(date_index: 1, period_index: 4)
      timetable_fourth.update(term_group_id: @term_group_first.id)
      timetable_fifth = term.timetables.find_by(date_index: 1, period_index: 5)
      timetable_fifth.update(term_group_id: @term_group_second.id)
      seat_first = timetable_first.seats.first
      seat_second = timetable_second.seats.first
      tutorial_contract_first = term.tutorial_contracts.where(
        term_student_id: term.term_students.first.id,
      ).first
      tutorial_contract_second = term.tutorial_contracts.where(
        term_student_id: term.term_students.first.id,
      ).second
      tutorial_contract_third = term.tutorial_contracts.where(
        term_student_id: term.term_students.first.id,
      ).third
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: @term_teacher_first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: @term_teacher_first.id)
      tutorial_contract_third.update(piece_count: 1, term_teacher_id: @term_teacher_first.id)
      piece_first = tutorial_contract_first.tutorial_pieces.first
      piece_second = tutorial_contract_second.tutorial_pieces.first
      piece_first.update(seat_id: seat_first.id)
      piece_second.update(seat_id: seat_second.id)
    end

    context '担任の追加時' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        term_group_term_teacher = TermGroupTermTeacher.new(
          term_group: @term_group_second,
          term_teacher: @term_teacher_first,
        )
        expect(term_group_term_teacher.save).to eq(false)
        expect(term_group_term_teacher.errors.full_messages).to include('講師の１日の空きコマの上限を超えています')
      end
    end

    context '担任の削除時' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        term_group_term_teacher_first = TermGroupTermTeacher.new(
          term_group: @term_group_first,
          term_teacher: @term_teacher_first,
        )
        term_group_term_teacher_second = TermGroupTermTeacher.new(
          term_group: @term_group_second,
          term_teacher: @term_teacher_first,
        )
        expect(term_group_term_teacher_first.save).to eq(true)
        expect(term_group_term_teacher_second.save).to eq(true)
        expect(term_group_term_teacher_first.destroy).to eq(false)
        expect(term_group_term_teacher_first.errors.full_messages).to include('講師の１日の空きコマの上限を超えています')
      end
    end
  end
end
