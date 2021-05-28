# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '生徒の編集ページ', type: :system do
  describe '生徒の追加' do
    before :each do
      @room = FactoryBot.create(:room)
      stub_authenticate_user
      stub_current_room @room
    end

    it '生徒が新規追加される' do
      visit students_path
      click_on '新規'
      fill_in 'student_name', with: '生徒０１'
      select '中1', from: 'student_school_grade'
      fill_in 'student_email', with: 'student01@example.com'
      click_on '保存'
      expect(page).to have_content '生徒０１'
      expect(page).to have_content '中1'
      expect(page).to have_content 'student01@example.com'
    end

    it 'エラーが表示される' do
      visit students_path
      click_on '新規'
      click_on '保存'
      expect(page).to have_content '生徒名は1文字以上で入力してください'
    end
  end

  describe '生徒の編集' do
    before :each do
      @student = FactoryBot.create(:student)
      @room = @student.room
      stub_authenticate_user
      stub_current_room @room
    end

    it '生徒が更新される' do
      visit students_path
      click_on '編集'
      fill_in 'student_name', with: '生徒０２'
      select '中2', from: 'student_school_grade'
      fill_in 'student_email', with: 'student02@example.com'
      click_on '保存'
      expect(page).to have_content '生徒０２'
      expect(page).to have_content '中2'
      expect(page).to have_content 'student02@example.com'
    end

    it 'エラーが表示される' do
      visit students_path
      click_on '編集'
      fill_in 'student_name', with: ''
      select '選択してください', from: 'student_school_grade'
      fill_in 'student_email', with: ''
      click_on '保存'
      expect(page).to have_content '生徒名は1文字以上で入力してください'
    end
  end

  describe '生徒の削除' do
    before :each do
      @student = FactoryBot.create(:student)
      @room = @student.room
      stub_authenticate_user
      stub_current_room @room
    end

    it '生徒が削除される' do
      visit students_path
      click_on '削除'
      within('.modal') do
        click_on '削除'
      end
      expect(page).to have_no_content '生徒０１'
      expect(page).to have_no_content '中1'
      expect(page).to have_no_content 'student01@example.com'
      expect(@student.reload.is_deleted).to eq(true)
    end
  end
end
