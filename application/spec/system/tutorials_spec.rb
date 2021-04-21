# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '個別科目の編集ページ', type: :system do
  describe '個別科目の追加' do
    before :each do
      @room = FactoryBot.create(:room)
      stub_authenticate_user
      stub_current_room @room
    end

    it '個別科目が新規追加される' do
      visit tutorials_path
      click_on '新規'
      fill_in 'tutorial_order', with: 1
      fill_in 'tutorial_name', with: '個別科目1'
      fill_in 'tutorial_short_name', with: 'T'
      click_on '保存'
      expect(page).to have_content '個別科目1'
      expect(page).to have_content 'T'
      expect(page).to have_content '1'
    end

    it 'エラーが表示される' do
      visit tutorials_path
      click_on '新規'
      click_on '保存'
      expect(page).to have_content '個別科目名は1文字以上で入力してください'
      expect(page).to have_content '短縮名は1文字で入力してください'
      expect(page).to have_content '表示順は数値で入力してください'
    end
  end

  describe '個別科目の編集' do
    before :each do
      @tutorial = FactoryBot.create(:tutorial)
      @room = @tutorial.room
      stub_authenticate_user
      stub_current_room @room
    end

    it '個別科目が更新される' do
      visit tutorials_path
      click_on '編集'
      fill_in 'tutorial_order', with: 2
      fill_in 'tutorial_name', with: '個別科目2'
      fill_in 'tutorial_short_name', with: 't'
      click_on '保存'
      expect(page).to have_content '個別科目2'
      expect(page).to have_content 't'
      expect(page).to have_content '2'
    end

    it 'エラーが表示される' do
      visit tutorials_path
      click_on '新規'
      fill_in 'tutorial_order', with: ''
      fill_in 'tutorial_name', with: ''
      fill_in 'tutorial_short_name', with: ''
      click_on '保存'
      expect(page).to have_content '個別科目名は1文字以上で入力してください'
      expect(page).to have_content '短縮名は1文字で入力してください'
      expect(page).to have_content '表示順は数値で入力してください'
    end
  end

  describe '個別科目の削除' do
    before :each do
      @tutorial = FactoryBot.create(:tutorial)
      @room = @tutorial.room
      stub_authenticate_user
      stub_current_room @room
    end

    it '個別科目が削除される' do
      visit tutorials_path
      click_on '削除'
      within('.modal') do
        click_on '削除'
      end
      expect(page).to have_no_content '個別科目1'
      expect(@tutorial.reload.is_deleted).to eq(true)
    end
  end
end
