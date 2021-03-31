require 'rails_helper'

RSpec.describe Seat, type: :model do
  describe 'ダブルブッキングバリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 0)
      @term_teacher_first = term.term_teachers.first
      @term_teacher_second = term.term_teachers.second
      @first = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).first
      @second = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).second
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
      term.teacher_optimization_rules.first.update(occupation_limit: 4, occupation_costs: [0, 18, 3, 0, 6])
      @term_teacher_first = term.term_teachers.first
      @term_teacher_second = term.term_teachers.second
      @first = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).first
      @second = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 2).first
      @third = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 3).first
      @fourth = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 4).first
      @fifth = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 5).first
      @sixth = term.seats.joins(:timetable).where('timetables.date_index': 2, 'timetables.period_index': 1).first
    end

    context '座席の新規設定時(term_teacher_id : nil -> integer)' do
      it '最大コマ数を越した場合にupdate失敗' do
        expect(@first.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@first.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@second.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@second.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@third.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@third.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@fourth.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@fourth.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@fifth.update(term_teacher_id: @term_teacher_first.id)).to eq(false)
        expect(@fifth.reload.term_teacher_id).to eq(nil)
        expect(@fifth.errors.full_messages).to include('講師の１日の上限コマを超えています')
      end
    end

    context '座席の追加設定時(term_teacher_id : integer -> integer)' do
      it '最大コマ数を越した場合にupdate失敗' do
        expect(@first.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@first.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@second.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@second.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@third.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@third.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@fourth.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@fourth.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@fifth.update(term_teacher_id: @term_teacher_second.id)).to eq(true)
        expect(@fifth.reload.term_teacher_id).to eq(@term_teacher_second.id)
        expect(@fifth.update(term_teacher_id: @term_teacher_first.id)).to eq(false)
        expect(@fifth.reload.term_teacher_id).to eq(@term_teacher_second.id)
        expect(@fifth.errors.full_messages).to include('講師の１日の上限コマを超えています')
      end
    end
  end

  describe '１日の空きコマ数上限バリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(2, 0)
      @term_teacher_first = term.term_teachers.first
      @term_teacher_second = term.term_teachers.second
      @first = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 1).first
      @second = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 2).first
      @third = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 3).first
      @fourth = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 4).first
      @fifth = term.seats.joins(:timetable).where('timetables.date_index': 1, 'timetables.period_index': 5).first
      @sixth = term.seats.joins(:timetable).where('timetables.date_index': 2, 'timetables.period_index': 1).first
    end

    context '座席の新規設定時(term_teacher_id : nil -> integer)' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        expect(@first.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@first.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@third.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@third.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@fifth.update(term_teacher_id: @term_teacher_first.id)).to eq(false)
        expect(@fifth.reload.term_teacher_id).to eq(nil)
        expect(@fifth.errors.full_messages).to include('講師の１日の空きコマの上限を超えています')
      end
    end

    context '座席の追加設定時(term_teacher_id : integer -> integer)' do
      it '移転先で最大空きコマ数を越した場合にupdate失敗' do
        expect(@first.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@first.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@third.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@third.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@fifth.update(term_teacher_id: @term_teacher_second.id)).to eq(true)
        expect(@fifth.reload.term_teacher_id).to eq(@term_teacher_second.id)
        expect(@fifth.update(term_teacher_id: @term_teacher_first.id)).to eq(false)
        expect(@fifth.reload.term_teacher_id).to eq(@term_teacher_second.id)
        expect(@fifth.errors.full_messages).to include('講師の１日の空きコマの上限を超えています')
      end
    end

    context '座席の追加設定時(term_teacher_id : integer -> integer)' do
      it '移転元で最大空きコマ数を越した場合にupdate失敗' do
        expect(@first.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@first.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@third.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@third.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@fourth.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@fourth.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@third.update(term_teacher_id: @term_teacher_second.id)).to eq(false)
        expect(@third.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@third.errors.full_messages).to include('講師の１日の空きコマの上限を超えています')
      end
    end

    context '座席の削除設定時(term_teacher_id : integer -> nil)' do
      it '最大空きコマ数を越した場合にupdate失敗' do
        expect(@first.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@first.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@third.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@third.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@fourth.update(term_teacher_id: @term_teacher_first.id)).to eq(true)
        expect(@fourth.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@third.update(term_teacher_id: nil)).to eq(false)
        expect(@third.reload.term_teacher_id).to eq(@term_teacher_first.id)
        expect(@third.errors.full_messages).to include('講師の１日の空きコマの上限を超えています')
      end
    end
  end
end
