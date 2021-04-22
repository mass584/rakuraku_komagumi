# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '生徒の編集ページ', type: :system do
  describe '生徒の追加' do
    before :each do
      @term = create_normal_term
      @room = @term.room
      FactoryBot.create(:student, room: @room)
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '生徒が新規追加される' do
      visit term_students_path
      click_on '新規'
      select '生徒1', from: 'term_student_student_id'
      click_on '保存'
      expect(page).to have_content '生徒1'
      expect(page).to have_content '中1'
    end

    it 'エラーが表示される' do
      visit term_students_path
      click_on '新規'
      click_on '保存'
      expect(page).to have_content '生徒を入力してください'
    end
  end

  describe '生徒のステータス編集' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(0, 1)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it 'ステータスが更新される' do
      visit term_students_path
      click_on '編集'
      select '確定', from: 'term_student_vacancy_status'
      click_on '保存'
      expect(page).to have_no_content '編集中'
      expect(page).to have_content '確定'
      expect(@term.term_students.first.reload.vacancy_status).to eq('fixed')
    end
  end
end
