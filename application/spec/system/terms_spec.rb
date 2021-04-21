# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'スケジュールの編集ページ', type: :system do
  describe 'スケジュールの追加' do
    before :each do
      @room = FactoryBot.create(:room)
      stub_authenticate_user
      stub_current_room @room
    end

    it '通常スケジュールが新規追加される' do
      visit terms_path
      click_on '新規'
      fill_in 'term_name', with: '1学期'
      select '通常期', from: 'term_term_type'
      fill_in 'term_year', with: 2020
      fill_in 'term_begin_at', with: '2020/04/13'
      fill_in 'term_end_at', with: '2020/07/26'
      fill_in 'term_period_count', with: 6
      fill_in 'term_seat_count', with: 7
      fill_in 'term_position_count', with: 2
      click_on '保存'
      expect(page).to have_content '2020年度'
      expect(page).to have_content '1学期'
      expect(page).to have_content '通常期'
      expect(page).to have_content '2020/04/13(月)'
      expect(page).to have_content '2020/07/26(日)'
      expect(page).to have_content '6時限'
      expect(page).to have_content '7席'
      expect(page).to have_content '1対2'
    end

    it '講習スケジュールが新規追加される' do
      visit terms_path
      click_on '新規'
      fill_in 'term_name', with: '春期講習'
      select '講習期', from: 'term_term_type'
      fill_in 'term_year', with: 2020
      fill_in 'term_begin_at', with: '2020/03/30'
      fill_in 'term_end_at', with: '2020/04/12'
      fill_in 'term_period_count', with: 6
      fill_in 'term_seat_count', with: 7
      fill_in 'term_position_count', with: 2
      click_on '保存'
      expect(page).to have_content '2020年度'
      expect(page).to have_content '春期講習'
      expect(page).to have_content '講習期'
      expect(page).to have_content '2020/03/30(月)'
      expect(page).to have_content '2020/04/12(日)'
      expect(page).to have_content '6時限'
      expect(page).to have_content '7席'
      expect(page).to have_content '1対2'
    end

    it 'テスト対策スケジュールが新規追加される' do
      visit terms_path
      click_on '新規'
      fill_in 'term_name', with: 'テスト対策１月'
      select 'テスト対策', from: 'term_term_type'
      fill_in 'term_year', with: 2020
      fill_in 'term_begin_at', with: '2021/01/01'
      fill_in 'term_end_at', with: '2021/01/03'
      fill_in 'term_period_count', with: 6
      fill_in 'term_seat_count', with: 7
      fill_in 'term_position_count', with: 2
      click_on '保存'
      expect(page).to have_content '2020年度'
      expect(page).to have_content 'テスト対策１月'
      expect(page).to have_content 'テスト対策'
      expect(page).to have_content '2021/01/01(金)'
      expect(page).to have_content '2021/01/03(日)'
      expect(page).to have_content '6時限'
      expect(page).to have_content '7席'
      expect(page).to have_content '1対2'
    end

    it 'エラーが表示される' do
      visit terms_path
      click_on '新規'
      click_on '保存'
      expect(page).to have_content 'スケジュール名は1文字以上で入力してください'
      expect(page).to have_content '期間種別を入力してください'
      expect(page).to have_content '年度は数値で入力してください'
      expect(page).to have_content '時限数は数値で入力してください'
      expect(page).to have_content '座席数は数値で入力してください'
      expect(page).to have_content '座席あたりの生徒数は数値で入力してください'
    end
  end

  describe 'スケジュールの編集' do
    before :each do
      @term = FactoryBot.create(:spring_term)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
    end

    it 'スケジュールが更新される' do
      visit terms_path
      click_on '編集'
      fill_in 'term_name', with: 'スケジュール'
      fill_in 'term_year', with: 2021
      click_on '保存'
      expect(page).to have_content 'スケジュール'
      expect(page).to have_content 2021
    end

    it 'エラーが表示される' do
      visit terms_path
      click_on '編集'
      fill_in 'term_name', with: ''
      fill_in 'term_year', with: ''
      click_on '保存'
      expect(page).to have_content 'スケジュール名は1文字以上で入力してください'
      expect(page).to have_content '年度は数値で入力してください'
    end
  end
end
