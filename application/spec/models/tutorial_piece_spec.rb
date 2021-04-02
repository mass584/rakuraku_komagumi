require 'rails_helper'

RSpec.describe TutorialPiece, type: :model do
  describe 'seat.term_teacher_idの同時変更' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 2)
      tutorial_contract_first = term.tutorial_contracts.find_by(term_student_id: term.term_students.first.id)
      tutorial_contract_second = term.tutorial_contracts.find_by(term_student_id: term.term_students.second.id)
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      @first = tutorial_contract_first.tutorial_pieces.first
      @second = tutorial_contract_second.tutorial_pieces.first
      @seat = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).first
    end

    context '座席に１人目を割り当てた時' do
      it 'seat.term_teacher_idが更新される' do
        @first.update(seat_id: @seat.id)
        expect(@seat.reload.term_teacher_id).to eq(@first.tutorial_contract.term_teacher_id)
      end
    end

    context '座席から全てのコマの割り当てを解除した時' do
      it 'seat.term_teacher_idが更新される' do
        @first.update(seat_id: @seat.id)
        @second.update(seat_id: @seat.id)
        @first.update(seat_id: nil)
        expect(@seat.reload.term_teacher_id).to eq(@first.tutorial_contract.term_teacher_id)
        @second.update(seat_id: nil)
        expect(@seat.reload.term_teacher_id).to eq(nil)
      end
    end
  end

  describe '座席の最大人数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 3)
      tutorial_contract_first = term.tutorial_contracts.find_by(term_student_id: term.term_students.first.id)
      tutorial_contract_second = term.tutorial_contracts.find_by(term_student_id: term.term_students.second.id)
      tutorial_contract_third = term.tutorial_contracts.find_by(term_student_id: term.term_students.third.id)
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      tutorial_contract_third.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      @first = tutorial_contract_first.tutorial_pieces.first
      @second = tutorial_contract_second.tutorial_pieces.first
      @third = tutorial_contract_third.tutorial_pieces.first
      @seat_first = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).first
      @seat_second = term.seats.joins(:timetable).where('timetables.date_index': 2, 'timetables.period_index': 1).first
    end

    context '座席の新規設定時(seat_id : nil -> integer)' do
      it '配置先の座席あたりのコマ数がseat.position_countより大きくなる場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_first.id)).to eq(true)
        expect(@second.reload.seat_id).to eq(@seat_first.id)
        expect(@third.update(seat_id: @seat_first.id)).to eq(false)
        expect(@third.reload.seat_id).to eq(nil)
        expect(@third.errors.full_messages).to include('座席の最大人数をオーバーしています')
      end
    end

    context '座席の変更設定時(seat_id : integer -> integer)' do
      it '配置先の座席あたりのコマ数がseat.position_countより大きくなる場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_first.id)).to eq(true)
        expect(@second.reload.seat_id).to eq(@seat_first.id)
        expect(@third.update(seat_id: @seat_second.id)).to eq(true)
        expect(@third.reload.seat_id).to eq(@seat_second.id)
        expect(@third.update(seat_id: @seat_first.id)).to eq(false)
        expect(@third.reload.seat_id).to eq(@seat_second.id)
        expect(@third.errors.full_messages).to include('座席の最大人数をオーバーしています')
      end
    end
  end

  describe '担任講師バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 3)
      tutorial_contract_first = term.tutorial_contracts.find_by(term_student_id: term.term_students.first.id)
      tutorial_contract_second = term.tutorial_contracts.find_by(term_student_id: term.term_students.second.id)
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: term.term_teachers.second.id)
      @first = tutorial_contract_first.tutorial_pieces.first
      @second = tutorial_contract_second.tutorial_pieces.first
      @seat_first = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).first
      @seat_second = term.seats.joins(:timetable).where('timetables.date_index': 2, 'timetables.period_index': 1).first
    end

    context '座席の新規設定時(seat_id : nil -> integer)' do
      it 'tutorial_contract.term_teacher_idとseat.term_teacher_idが一致しない場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_first.id)).to eq(false)
        expect(@second.reload.seat_id).to eq(nil)
        expect(@second.errors.full_messages).to include('座席に割り当てられた講師と担当講師が一致しません')
      end
    end

    context '座席の追加設定時(seat_id : integer -> integer)' do
      it 'tutorial_contract.term_teacher_idとseat.term_teacher_idが一致しない場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_second.id)).to eq(true)
        expect(@second.reload.seat_id).to eq(@seat_second.id)
        expect(@second.update(seat_id: @seat_first.id)).to eq(false)
        expect(@second.reload.seat_id).to eq(@seat_second.id)
        expect(@second.errors.full_messages).to include('座席に割り当てられた講師と担当講師が一致しません')
      end
    end
  end

  describe 'ダブルブッキングバリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 1)
      tutorial_contract_first = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).first
      tutorial_contract_second = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).second
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: term.term_teachers.second.id)
      @first = tutorial_contract_first.tutorial_pieces.first
      @second = tutorial_contract_second.tutorial_pieces.first
      @seat_first = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).first
      @seat_second = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).second
      @seat_third = term.seats.joins(:timetable).where('timetables.date_index': 2, 'timetables.period_index': 1).first
    end

    context '座席の新規設定時(seat_id : nil -> integer)' do
      it '生徒の予定が重複した場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_second.id)).to eq(false)
        expect(@second.reload.seat_id).to eq(nil)
        expect(@second.errors.full_messages).to include('生徒の予定が重複しています')
      end
    end

    context '座席の追加設定時(seat_id : integer -> integer)' do
      it '生徒の予定が重複した場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_third.id)).to eq(true)
        expect(@second.reload.seat_id).to eq(@seat_third.id)
        expect(@second.update(seat_id: @seat_second.id)).to eq(false)
        expect(@second.reload.seat_id).to eq(@seat_third.id)
        expect(@second.errors.full_messages).to include('生徒の予定が重複しています')
      end
    end
  end

  describe '１日のコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(4, 1)
      tutorial_contract_first = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).first
      tutorial_contract_second = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).second
      tutorial_contract_third = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).third
      tutorial_contract_fourth = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).fourth
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: term.term_teachers.second.id)
      tutorial_contract_third.update(piece_count: 1, term_teacher_id: term.term_teachers.third.id)
      tutorial_contract_fourth.update(piece_count: 1, term_teacher_id: term.term_teachers.fourth.id)
      @first = tutorial_contract_first.tutorial_pieces.first
      @second = tutorial_contract_second.tutorial_pieces.first
      @third = tutorial_contract_third.tutorial_pieces.first
      @fourth = tutorial_contract_fourth.tutorial_pieces.first
      @seat_first = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).first
      @seat_second = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 2).first
      @seat_third = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 3).first
      @seat_fourth = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 4).first
      @seat_fifth = term.seats.joins(:timetable).where('timetables.date_index': 2, 'timetables.period_index': 1).first
    end

    context '座席の新規設定時(seat_id : nil -> integer)' do
      it '最大コマ数を越した場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_second.id)).to eq(true)
        expect(@second.reload.seat_id).to eq(@seat_second.id)
        expect(@third.update(seat_id: @seat_third.id)).to eq(true)
        expect(@third.reload.seat_id).to eq(@seat_third.id)
        expect(@fourth.update(seat_id: @seat_fourth.id)).to eq(false)
        expect(@fourth.reload.seat_id).to eq(nil)
        expect(@fourth.errors.full_messages).to include('生徒の１日の合計コマの上限を超えています')
      end
    end

    context '座席の追加設定時(seat_id : integer -> integer)' do
      it '最大コマ数を越した場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_second.id)).to eq(true)
        expect(@second.reload.seat_id).to eq(@seat_second.id)
        expect(@third.update(seat_id: @seat_third.id)).to eq(true)
        expect(@third.reload.seat_id).to eq(@seat_third.id)
        expect(@fourth.update(seat_id: @seat_fifth.id)).to eq(true)
        expect(@fourth.reload.seat_id).to eq(@seat_fifth.id)
        expect(@fourth.update(seat_id: @seat_fourth.id)).to eq(false)
        expect(@fourth.reload.seat_id).to eq(@seat_fifth.id)
        expect(@fourth.errors.full_messages).to include('生徒の１日の合計コマの上限を超えています')
      end
    end
  end

  describe '１日の空きコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(3, 1)
      tutorial_contract_first = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).first
      tutorial_contract_second = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).second
      tutorial_contract_third = term.tutorial_contracts.where(term_student_id: term.term_students.first.id).third
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: term.term_teachers.second.id)
      tutorial_contract_third.update(piece_count: 1, term_teacher_id: term.term_teachers.third.id)
      @first = tutorial_contract_first.tutorial_pieces.first
      @second = tutorial_contract_second.tutorial_pieces.first
      @third = tutorial_contract_third.tutorial_pieces.first
      @seat_first = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).first
      @seat_second = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 2).first
      @seat_third = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 3).first
      @seat_fourth = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 4).first
      @seat_fifth = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 5).first
      @seat_sixth = term.seats.joins(:timetable).where('timetables.date_index': 2, 'timetables.period_index': 1).first
    end

    context '座席の新規設定時(seat_id : nil -> integer)' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_third.id)).to eq(true)
        expect(@second.reload.seat_id).to eq(@seat_third.id)
        expect(@third.update(seat_id: @seat_fifth.id)).to eq(false)
        expect(@third.reload.seat_id).to eq(nil)
        expect(@third.errors.full_messages).to include('生徒の１日の空きコマの上限を超えています')
      end
    end

    context '座席の追加設定時(seat_id : integer -> integer)' do
      it '移転先で最大空きコマ数を越した場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_third.id)).to eq(true)
        expect(@second.reload.seat_id).to eq(@seat_third.id)
        expect(@third.update(seat_id: @seat_fourth.id)).to eq(true)
        expect(@third.reload.seat_id).to eq(@seat_fourth.id)
        expect(@third.update(seat_id: @seat_fifth.id)).to eq(false)
        expect(@third.reload.seat_id).to eq(@seat_fourth.id)
        expect(@third.errors.full_messages).to include('生徒の１日の空きコマの上限を超えています')
      end
    end

    context '座席の追加設定時(seat_id : integer -> integer)' do
      it '移転元で最大空きコマ数を越した場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_third.id)).to eq(true)
        expect(@second.reload.seat_id).to eq(@seat_third.id)
        expect(@third.update(seat_id: @seat_fourth.id)).to eq(true)
        expect(@third.reload.seat_id).to eq(@seat_fourth.id)
        expect(@second.update(seat_id: @seat_sixth.id)).to eq(false)
        expect(@second.reload.seat_id).to eq(@seat_third.id)
        expect(@second.errors.full_messages).to include('生徒の１日の空きコマの上限を超えています')
      end
    end

    context '座席の削除設定時(seat_id : integer -> nil)' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        expect(@first.update(seat_id: @seat_first.id)).to eq(true)
        expect(@first.reload.seat_id).to eq(@seat_first.id)
        expect(@second.update(seat_id: @seat_third.id)).to eq(true)
        expect(@second.reload.seat_id).to eq(@seat_third.id)
        expect(@third.update(seat_id: @seat_fourth.id)).to eq(true)
        expect(@third.reload.seat_id).to eq(@seat_fourth.id)
        expect(@second.update(seat_id: nil)).to eq(false)
        expect(@second.reload.seat_id).to eq(@seat_third.id)
        expect(@second.errors.full_messages).to include('生徒の１日の空きコマの上限を超えています')
      end
    end
  end

  describe '生徒の予定の空きバリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 1)
      tutorial_contract = term.tutorial_contracts.first
      tutorial_contract.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      @tutorial_piece = tutorial_contract.tutorial_pieces.first
      @seat = term.seats.first
      @timetable = @seat.timetable
      student_vacancy = tutorial_contract.term_student.student_vacancies.find_by(timetable_id: @timetable.id)
      student_vacancy.update(is_vacant: false)
    end

    it '設定先の生徒の予定が空いていない場合、update失敗' do
      expect(@tutorial_piece.update(seat_id: @seat.id)).to eq(false)
      expect(@tutorial_piece.reload.seat_id).to eq(nil)
      expect(@tutorial_piece.errors.full_messages).to include('生徒の予定が空いていません')
    end
  end
end
