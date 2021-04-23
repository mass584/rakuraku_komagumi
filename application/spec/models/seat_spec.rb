require 'rails_helper'

RSpec.describe Seat, type: :model do
  describe '集団や休講との重複検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 0)
      @term_teacher = term.term_teachers.first
      @term_group = term.term_groups.first
      @timetables = timetables(term)
      @seats = seats(term)
    end

    it '休講と重複した場合にupdate失敗' do
      @timetables[0].update(is_closed: true)
      expect(@seats[0].update(term_teacher_id: @term_teacher.id)).to eq(false)
      expect(@seats[0].errors.full_messages).to include('休講に設定されています')
    end

    it '集団科目と重複した場合にupdate失敗' do
      @timetables[0].update(term_group_id: @term_group.id)
      expect(@seats[0].update(term_teacher_id: @term_teacher.id)).to eq(false)
      expect(@seats[0].errors.full_messages).to include('集団科目が割り当てられています')
    end
  end

  describe 'ダブルブッキングバリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 0)
      @term_teacher_first = term.term_teachers.first
      @term_teacher_second = term.term_teachers.second
      @first = term.seats.joins(:timetable).where('timetables.date_index': 1,
                                                  'timetables.period_index': 1).first
      @second = term.seats.joins(:timetable).where('timetables.date_index': 1,
                                                   'timetables.period_index': 1).second
    end

    context '講師の新規設定時(term_teacher_id : nil -> integer)' do
      it '講師の予定が重複した場合にupdate失敗' do
        expect(@first.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@first.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@second.update(term_teacher_id: @term_teacher_first.id)).to eq(false)
        expect(@second.reload.term_teacher_id).to eq(nil)
        expect(@second.errors.full_messages).to include('講師の予定が重複しています')
      end
    end

    context '講師の変更設定時(term_teacher_id : integer -> integer)' do
      it '講師の予定が重複した場合にupdate失敗' do
        expect(@first.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@first.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@second.update(term_teacher_id: @term_teacher_second.id)).to eq(true)
        expect(@second.reload.term_teacher_id).to eq(@term_teacher_second.id)
        expect(@second.update(term_teacher_id: @term_teacher_first.id)).to eq(false)
        expect(@second.reload.term_teacher_id).to eq(@term_teacher_second.id)
        expect(@second.errors.full_messages).to include('講師の予定が重複しています')
      end
    end
  end

  describe '１日のコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 0)
      term.teacher_optimization_rules.first.update(occupation_limit: 4,
                                                   occupation_costs: [0, 18, 3, 0, 6])
      timetables = timetables(term)
      @seats = seats(term)
      @term_teacher_first = term.term_teachers.first
      @term_teacher_second = term.term_teachers.second
      term_group = term.term_groups.first
      term_group.update(term_teacher_id: @term_teacher_first.id)
      timetables[0].update(term_group_id: term_group.id)
    end

    context '座席の新規設定時(term_teacher_id : nil -> integer)' do
      it '最大コマ数を越した場合にupdate失敗' do
        expect(@seats[1].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[1].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[2].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[2].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[3].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[3].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[4].update(term_teacher_id: @term_teacher_first.id)).to eq(false)
        expect(@seats[4].reload.term_teacher_id).to eq(nil)
        expect(@seats[4].errors.full_messages).to include('講師の１日の合計コマの上限を超えています')
      end
    end

    context '座席の追加設定時(term_teacher_id : integer -> integer)' do
      it '最大コマ数を越した場合にupdate失敗' do
        expect(@seats[1].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[1].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[2].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[2].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[3].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[3].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[4].update(term_teacher_id: @term_teacher_second.id)).to eq(true)
        expect(@seats[4].reload.term_teacher_id).to eq(@term_teacher_second.id)
        expect(@seats[4].update(term_teacher_id: @term_teacher_first.id)).to eq(false)
        expect(@seats[4].reload.term_teacher_id).to eq(@term_teacher_second.id)
        expect(@seats[4].errors.full_messages).to include('講師の１日の合計コマの上限を超えています')
      end
    end
  end

  describe '１日の空きコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 0)
      timetables = timetables(term)
      @seats = seats(term)
      @term_teacher_first = term.term_teachers.first
      @term_teacher_second = term.term_teachers.second
      term_group = term.term_groups.first
      term_group.update(term_teacher_id: @term_teacher_first.id)
      timetables[0].update(term_group_id: term_group.id)
    end

    context '座席の新規設定時(term_teacher_id : nil -> integer)' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        expect(@seats[2].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[2].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[4].update(term_teacher_id: @term_teacher_first.id)).to eq(false)
        expect(@seats[4].reload.term_teacher_id).to eq(nil)
        expect(@seats[4].errors.full_messages).to include('講師の１日の空きコマの上限を超えています')
      end
    end

    context '座席の追加設定時(term_teacher_id : integer -> integer)' do
      it '移転先で最大空きコマ数を越した場合にupdate失敗' do
        expect(@seats[2].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[2].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[4].update(term_teacher_id: @term_teacher_second.id)).to eq(true)
        expect(@seats[4].reload.term_teacher_id).to eq(@term_teacher_second.id)
        expect(@seats[4].update(term_teacher_id: @term_teacher_first.id)).to eq(false)
        expect(@seats[4].reload.term_teacher_id).to eq(@term_teacher_second.id)
        expect(@seats[4].errors.full_messages).to include('講師の１日の空きコマの上限を超えています')
      end
    end

    context '座席の追加設定時(term_teacher_id : integer -> integer)' do
      it '移転元で最大空きコマ数を越した場合にupdate失敗' do
        expect(@seats[2].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[2].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[3].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[3].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[2].update(term_teacher_id: @term_teacher_second.id)).to eq(false)
        expect(@seats[2].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[2].errors.full_messages).to include('講師の１日の空きコマの上限を超えています')
      end
    end

    context '座席の削除設定時(term_teacher_id : integer -> nil)' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        expect(@seats[2].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[2].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[3].update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@seats[3].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[2].update(term_teacher_id: nil)).to eq(false)
        expect(@seats[2].reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@seats[2].errors.full_messages).to include('講師の１日の空きコマの上限を超えています')
      end
    end
  end

  describe '講師の予定の空きバリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 0)
      @term_teacher = term.term_teachers.first
      @seat = term.seats.first
      @timetable = @seat.timetable
      teacher_vacancy = @timetable.teacher_vacancies.find_by(timetable_id: @timetable.id,
                                                             term_teacher_id: @term_teacher.id)
      teacher_vacancy.update(is_vacant: false)
    end

    it '設定先の講師の予定が空いていない場合、update失敗' do
      expect(@seat.update(term_teacher_id: @term_teacher.id)).to eq(false)
      expect(@seat.reload.term_teacher_id).to eq(nil)
      expect(@seat.errors.full_messages).to include('講師の予定が空いていません')
    end
  end
end
