# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '講師の編集ページ', type: :system do
  describe '講師の追加' do
    before :each do
      @term = create_normal_term
      @room = @term.room
      @teacher = FactoryBot.create(:teacher, room: @room)
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '講師が新規追加される' do
      visit term_teachers_path
      click_on '新規'
      select '講師1', from: 'term_teacher_teacher_id'
      click_on '保存'
      expect(page).to have_content '講師1'
    end

    it 'エラーが表示される' do
      visit term_teachers_path
      click_on '新規'
      click_on '保存'
      expect(page).to have_content '講師を入力してください'
    end
  end

  describe '生徒のステータス編集' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(1, 0)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it 'ステータスが更新される' do
      visit term_teachers_path
      click_on '編集'
      select '確定', from: 'term_teacher_vacancy_status'
      click_on '保存'
      expect(page).to have_no_content '編集中'
      expect(page).to have_content '確定'
      expect(@term.term_teachers.first.reload.vacancy_status).to eq('fixed')
    end
  end
end
