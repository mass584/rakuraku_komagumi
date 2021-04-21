# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '集団科目の編集ページ', type: :system do
  describe '集団科目の追加' do
    before :each do
      @room = FactoryBot.create(:room)
      stub_authenticate_user
      stub_current_room @room
    end

    it '集団科目が新規追加される' do
      visit groups_path
      click_on '新規'
      fill_in 'group_order', with: 1
      fill_in 'group_name', with: '集団科目1'
      fill_in 'group_short_name', with: 'T'
      click_on '保存'
      expect(page).to have_content '集団科目1'
      expect(page).to have_content 'T'
      expect(page).to have_content '1'
    end
  end

  describe '集団科目の編集' do
    before :each do
      @group = FactoryBot.create(:group)
      @room = @group.room
      stub_authenticate_user
      stub_current_room @room
    end

    it '集団科目が更新される' do
      visit groups_path
      click_on '編集'
      fill_in 'group_order', with: 2
      fill_in 'group_name', with: '集団科目2'
      fill_in 'group_short_name', with: 't'
      click_on '保存'
      expect(page).to have_content '集団科目2'
      expect(page).to have_content 't'
      expect(page).to have_content '2'
    end
  end

  describe '集団科目の削除' do
    before :each do
      @group = FactoryBot.create(:group)
      @room = @group.room
      stub_authenticate_user
      stub_current_room @room
    end

    it '集団科目が削除される' do
      visit groups_path
      click_on '削除'
      within('.modal') do
        click_on '削除'
      end
      expect(page).to have_no_content '集団科目1'
      expect(@group.reload.is_deleted).to eq(true)
    end
  end
end
