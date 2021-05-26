require 'rails_helper'

RSpec.describe TermSingleSchedule, type: :model do
  describe '講師の１日の空きコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 2)
      timetables = timetables(term)
      term_teacher = term.term_teachers.first
      term_group = term.term_groups.first
      term_group.update(term_teachers: [term_teacher])
      timetables[0].update(term_group_id: term_group.id)
      tutorial_contract_first = term.tutorial_contracts.first
      tutorial_contract_first.update(piece_count: 1, term_teacher: term_teacher)
      tutorial_contract_second = term.tutorial_contracts.second
      tutorial_contract_second.update(piece_count: 1, term_teacher: term_teacher)
      @tutorial_piece_first = tutorial_contract_first.tutorial_pieces.first
      @tutorial_piece_second = tutorial_contract_second.tutorial_pieces.first
      @seats = seats(term)
    end

    context '座席の新規時' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        term_schedule_first = TermSingleSchedule.new(seat_id: @seats[2].id, tutorial_piece_id: @tutorial_piece_first.id)
        expect(term_schedule_first.save).to eq(true)
        expect(@tutorial_piece_first.reload.seat_id).to eq(@seats[2].id)
        term_schedule_second = TermSingleSchedule.new(seat_id: @seats[4].id,
                                                      tutorial_piece_id: @tutorial_piece_second.id)
        expect(term_schedule_second.save).to eq(false)
        expect(@tutorial_piece_second.reload.seat_id).to eq(nil)
        expect(term_schedule_second.errors.full_messages).to include('講師の１日の最大空きコマ数を超えています')
      end
    end

    context '座席の移動時' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        term_schedule_first = TermSingleSchedule.new(seat_id: @seats[2].id, tutorial_piece_id: @tutorial_piece_first.id)
        expect(term_schedule_first.save).to eq(true)
        expect(@tutorial_piece_first.reload.seat_id).to eq(@seats[2].id)
        term_schedule_second = TermSingleSchedule.new(seat_id: @seats[3].id,
                                                      tutorial_piece_id: @tutorial_piece_first.id)
        expect(term_schedule_second.save).to eq(false)
        expect(@tutorial_piece_first.reload.seat_id).to eq(@seats[2].id)
        expect(term_schedule_second.errors.full_messages).to include('講師の１日の最大空きコマ数を超えています')
      end
    end

    context '座席の削除時' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        term_schedule_first = TermSingleSchedule.new(seat_id: @seats[2].id, tutorial_piece_id: @tutorial_piece_first.id)
        expect(term_schedule_first.save).to eq(true)
        expect(@tutorial_piece_first.reload.seat_id).to eq(@seats[2].id)
        term_schedule_second = TermSingleSchedule.new(seat_id: @seats[3].id,
                                                      tutorial_piece_id: @tutorial_piece_second.id)
        expect(term_schedule_second.save).to eq(true)
        expect(@tutorial_piece_second.reload.seat_id).to eq(@seats[3].id)
        term_schedule_third = TermSingleSchedule.new(seat_id: nil, tutorial_piece_id: @tutorial_piece_first.id)
        expect(term_schedule_third.save).to eq(false)
        expect(@tutorial_piece_first.reload.seat_id).to eq(@seats[2].id)
        expect(term_schedule_third.errors.full_messages).to include('講師の１日の最大空きコマ数を超えています')
      end
    end
  end

  describe '生徒の１日の空きコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(3, 1)
      term_teacher_first = term.term_teachers.first
      term_teacher_second = term.term_teachers.second
      term_teacher_third = term.term_teachers.third
      tutorial_contract_first = term.tutorial_contracts.first
      tutorial_contract_first.update(piece_count: 1, term_teacher: term_teacher_first)
      tutorial_contract_second = term.tutorial_contracts.second
      tutorial_contract_second.update(piece_count: 1, term_teacher: term_teacher_second)
      tutorial_contract_third = term.tutorial_contracts.third
      tutorial_contract_third.update(piece_count: 1, term_teacher: term_teacher_third)
      @tutorial_piece_first = tutorial_contract_first.tutorial_pieces.first
      @tutorial_piece_second = tutorial_contract_second.tutorial_pieces.first
      @tutorial_piece_third = tutorial_contract_third.tutorial_pieces.first
      @seats = seats(term)
    end

    context '座席の新規時' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        term_schedule_first = TermSingleSchedule.new(seat_id: @seats[0].id, tutorial_piece_id: @tutorial_piece_first.id)
        expect(term_schedule_first.save).to eq(true)
        expect(@tutorial_piece_first.reload.seat_id).to eq(@seats[0].id)
        term_schedule_second = TermSingleSchedule.new(seat_id: @seats[3].id,
                                                      tutorial_piece_id: @tutorial_piece_second.id)
        expect(term_schedule_second.save).to eq(false)
        expect(@tutorial_piece_second.reload.seat_id).to eq(nil)
        expect(term_schedule_second.errors.full_messages).to include('生徒の１日の最大空きコマ数を超えています')
      end
    end

    context '座席の移動時' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        term_schedule_first = TermSingleSchedule.new(seat_id: @seats[0].id, tutorial_piece_id: @tutorial_piece_first.id)
        expect(term_schedule_first.save).to eq(true)
        expect(@tutorial_piece_first.reload.seat_id).to eq(@seats[0].id)
        term_schedule_second = TermSingleSchedule.new(seat_id: @seats[2].id,
                                                      tutorial_piece_id: @tutorial_piece_second.id)
        expect(term_schedule_second.save).to eq(true)
        expect(@tutorial_piece_second.reload.seat_id).to eq(@seats[2].id)
        term_schedule_third = TermSingleSchedule.new(seat_id: @seats[3].id,
                                                     tutorial_piece_id: @tutorial_piece_second.id)
        expect(term_schedule_third.save).to eq(false)
        expect(@tutorial_piece_second.reload.seat_id).to eq(@seats[2].id)
        expect(term_schedule_third.errors.full_messages).to include('生徒の１日の最大空きコマ数を超えています')
      end
    end

    context '座席の削除時' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        term_schedule_first = TermSingleSchedule.new(seat_id: @seats[0].id, tutorial_piece_id: @tutorial_piece_first.id)
        expect(term_schedule_first.save).to eq(true)
        expect(@tutorial_piece_first.reload.seat_id).to eq(@seats[0].id)
        term_schedule_second = TermSingleSchedule.new(seat_id: @seats[2].id,
                                                      tutorial_piece_id: @tutorial_piece_second.id)
        expect(term_schedule_second.save).to eq(true)
        expect(@tutorial_piece_second.reload.seat_id).to eq(@seats[2].id)
        term_schedule_third = TermSingleSchedule.new(seat_id: @seats[3].id, tutorial_piece_id: @tutorial_piece_third.id)
        expect(term_schedule_third.save).to eq(true)
        expect(@tutorial_piece_third.reload.seat_id).to eq(@seats[3].id)
        term_schedule_fourth = TermSingleSchedule.new(seat_id: nil, tutorial_piece_id: @tutorial_piece_second.id)
        expect(term_schedule_fourth.save).to eq(false)
        expect(@tutorial_piece_second.reload.seat_id).to eq(@seats[2].id)
        expect(term_schedule_fourth.errors.full_messages).to include('生徒の１日の最大空きコマ数を超えています')
      end
    end
  end
end
