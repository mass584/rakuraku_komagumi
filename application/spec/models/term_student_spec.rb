require 'rails_helper'

RSpec.describe TermStudent, type: :model do
  describe '期間（通常期）に紐づいた生徒の作成' do
    before :each do
      term = create_normal_term
      student = FactoryBot.create(:student, room: term.room)
      @term_student = FactoryBot.create(:term_student, term: term, student: student)
    end

    context 'ネスト属性を指定しない時' do
      it 'TutorialContractとGroupContractとStudentVacancyが生成される' do
        expect(@term_student.student_vacancies.count).to eq(42)
        expect(@term_student.tutorial_contracts.count).to eq(5)
        expect(@term_student.group_contracts.count).to eq(2)
      end
    end
  end

  describe '期間（講習期）に紐づいた生徒の作成' do
    before :each do
      term = create_season_term
      student = FactoryBot.create(:student, room: term.room)
      @term_student = FactoryBot.create(:term_student, term: term, student: student)
    end

    context 'ネスト属性を指定しない時' do
      it 'TutorialContractとGroupContractとStudentVacancyが生成される' do
        expect(@term_student.student_vacancies.count).to eq(84)
        expect(@term_student.tutorial_contracts.count).to eq(5)
        expect(@term_student.group_contracts.count).to eq(2)
      end
    end
  end

  describe '期間（テスト対策）に紐づいた生徒の作成' do
    before :each do
      term = create_exam_planning_term
      student = FactoryBot.create(:student, room: term.room)
      @term_student = FactoryBot.create(:term_student, term: term, student: student)
    end

    context 'ネスト属性を指定しない時' do
      it 'TutorialContractとGroupContractとStudentVacancyが生成される' do
        expect(@term_student.student_vacancies.count).to eq(12)
        expect(@term_student.tutorial_contracts.count).to eq(5)
        expect(@term_student.group_contracts.count).to eq(2)
      end
    end
  end
end
