require 'rails_helper'

RSpec.describe TermTeacher, type: :model do
  describe '期間（通常期）に紐づいた講師の作成' do
    before :each do
      term = create_normal_term
      teacher = FactoryBot.create(:teacher, room: term.room)
      @term_teacher = FactoryBot.create(:term_teacher, term: term, teacher: teacher)
    end

    context 'ネスト属性を指定しない時' do
      it 'TeacherVacancyが生成される' do
        expect(@term_teacher.teacher_vacancies.count).to eq(42)
      end
    end
  end

  describe '期間（講習期）に紐づいた講師の作成' do
    before :each do
      term = create_season_term
      teacher = FactoryBot.create(:teacher, room: term.room)
      @term_teacher = FactoryBot.create(:term_teacher, term: term, teacher: teacher)
    end

    context 'ネスト属性を指定しない時' do
      it 'TeacherVacancyが生成される' do
        expect(@term_teacher.teacher_vacancies.count).to eq(84)
      end
    end
  end

  describe '期間（テスト対策）に紐づいた講師の作成' do
    before :each do
      term = create_exam_planning_term
      teacher = FactoryBot.create(:teacher, room: term.room)
      @term_teacher = FactoryBot.create(:term_teacher, term: term, teacher: teacher)
    end

    context 'ネスト属性を指定しない時' do
      it 'TeacherVacancyが生成される' do
        expect(@term_teacher.teacher_vacancies.count).to eq(12)
      end
    end
  end
end
