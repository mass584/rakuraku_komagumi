require 'rails_helper'

RSpec.describe Term, type: :model do
  describe '期間（通常期）の作成' do
    before :each do
      @term = FactoryBot.create(:first_term)
    end

    context 'ネスト属性を指定しない時' do
      it 'TimetableとBeginEndTimeが生成される' do
        expect(@term.student_optimization_rules.count).to eq(13)
        expect(@term.teacher_optimization_rules.count).to eq(1)
        expect(@term.begin_end_times.count).to eq(6)
        expect(@term.timetables.count).to eq(42)
        expect(@term.timetables.map(&:seats).map(&:count).sum).to eq(294)
      end
    end
  end

  describe '期間（講習期）の作成' do
    before :each do
      @term = FactoryBot.create(:spring_term)
    end

    context 'ネスト属性を指定しない時' do
      it 'TimetableとBeginEndTimeが生成される' do
        expect(@term.student_optimization_rules.count).to eq(13)
        expect(@term.teacher_optimization_rules.count).to eq(1)
        expect(@term.begin_end_times.count).to eq(6)
        expect(@term.timetables.count).to eq(84)
        expect(@term.timetables.map(&:seats).map(&:count).sum).to eq(588)
      end
    end
  end

  describe '期間（テスト対策）の作成' do
    before :each do
      @term = FactoryBot.create(:exam_planning_term)
    end

    context 'ネスト属性を指定しない時' do
      it 'TimetableとBeginEndTimeが生成される' do
        expect(@term.student_optimization_rules.count).to eq(13)
        expect(@term.teacher_optimization_rules.count).to eq(1)
        expect(@term.begin_end_times.count).to eq(4)
        expect(@term.timetables.count).to eq(12)
        expect(@term.timetables.map(&:seats).map(&:count).sum).to eq(84)
      end
    end
  end

  describe '期間（通常期）の自動最適化フラグ更新' do
    before :each do
      @term = FactoryBot.create(:first_term)
      @term.update(is_optimizing: true)
    end

    it 'ログが生成される' do
      expect(@term.optimization_logs.count).to eq(1)
    end
  end
end
