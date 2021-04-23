# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '講師の編集ページ', type: :system do
  describe '講師の追加' do
    before :each do
      @room = FactoryBot.create(:room)
      stub_authenticate_user
      stub_current_room @room
    end

    it '講師が新規追加される' do
      visit teachers_path
      click_on '新規'
      fill_in 'teacher_name', with: '講師０１'
      fill_in 'teacher_email', with: 'teacher01@example.com'
      click_on '保存'
      expect(page).to have_content '講師０１'
      expect(page).to have_content 'teacher01@example.com'
    end

    it 'エラーが表示される' do
      visit teachers_path
      click_on '新規'
      click_on '保存'
      expect(page).to have_content '講師名は1文字以上で入力してください'
      expect(page).to have_content 'メールアドレスを入力してください'
    end
  end

  describe '講師の編集' do
    before :each do
      @teacher = FactoryBot.create(:teacher)
      @room = @teacher.room
      stub_authenticate_user
      stub_current_room @room
    end

    it '講師が更新される' do
      visit teachers_path
      click_on '編集'
      fill_in 'teacher_name', with: '講師０２'
      fill_in 'teacher_email', with: 'teacher02@example.com'
      click_on '保存'
      expect(page).to have_content '講師０２'
      expect(page).to have_content 'teacher02@example.com'
    end

    it 'エラーが表示される' do
      visit teachers_path
      click_on '編集'
      fill_in 'teacher_name', with: ''
      fill_in 'teacher_email', with: ''
      click_on '保存'
      expect(page).to have_content '講師名は1文字以上で入力してください'
      expect(page).to have_content 'メールアドレスを入力してください'
    end
  end

  describe '講師の削除' do
    before :each do
      @teacher = FactoryBot.create(:teacher)
      @room = @teacher.room
      stub_authenticate_user
      stub_current_room @room
    end

    it '講師が削除される' do
      visit teachers_path
      click_on '削除'
      within('.modal') do
        click_on '削除'
      end
      expect(page).to have_no_content '講師０１'
      expect(@teacher.reload.is_deleted).to eq(true)
    end
  end
end
