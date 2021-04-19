# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '時間割りの編集ページ', type: :system do
  describe '開始時刻と終了時刻の編集' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(1, 1)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '開始時刻が表示・更新される' do
      visit timetables_path
      begin_end_times = @term.begin_end_times
      expect(find_by_id('begin_at_1').value).to eq I18n.l(begin_end_times.find_by(period_index: 1).begin_at)
      expect(find_by_id('begin_at_2').value).to eq I18n.l(begin_end_times.find_by(period_index: 2).begin_at)
      expect(find_by_id('begin_at_3').value).to eq I18n.l(begin_end_times.find_by(period_index: 3).begin_at)
      expect(find_by_id('begin_at_4').value).to eq I18n.l(begin_end_times.find_by(period_index: 4).begin_at)
      expect(find_by_id('begin_at_5').value).to eq I18n.l(begin_end_times.find_by(period_index: 5).begin_at)
      expect(find_by_id('begin_at_6').value).to eq I18n.l(begin_end_times.find_by(period_index: 6).begin_at)
      fill_in 'begin_at_1', with: '18:01'
      fill_in 'begin_at_2', with: '18:02'
      fill_in 'begin_at_3', with: '18:03'
      fill_in 'begin_at_4', with: '18:04'
      fill_in 'begin_at_5', with: '18:05'
      fill_in 'begin_at_6', with: '18:06'
      find_by_id('begin_at_6').native.send_keys :tab
      expect(find_by_id('begin_at_1').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 1).begin_at)
      expect(find_by_id('begin_at_2').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 2).begin_at)
      expect(find_by_id('begin_at_3').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 3).begin_at)
      expect(find_by_id('begin_at_4').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 4).begin_at)
      expect(find_by_id('begin_at_5').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 5).begin_at)
      expect(find_by_id('begin_at_6').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 6).begin_at)
    end

    it '終了時刻が表示・更新される' do
      visit timetables_path
      begin_end_times = @term.begin_end_times
      expect(find_by_id('end_at_1').value).to eq I18n.l(begin_end_times.find_by(period_index: 1).end_at)
      expect(find_by_id('end_at_2').value).to eq I18n.l(begin_end_times.find_by(period_index: 2).end_at)
      expect(find_by_id('end_at_3').value).to eq I18n.l(begin_end_times.find_by(period_index: 3).end_at)
      expect(find_by_id('end_at_4').value).to eq I18n.l(begin_end_times.find_by(period_index: 4).end_at)
      expect(find_by_id('end_at_5').value).to eq I18n.l(begin_end_times.find_by(period_index: 5).end_at)
      expect(find_by_id('end_at_6').value).to eq I18n.l(begin_end_times.find_by(period_index: 6).end_at)
      fill_in 'end_at_1', with: '19:01'
      fill_in 'end_at_2', with: '19:02'
      fill_in 'end_at_3', with: '19:03'
      fill_in 'end_at_4', with: '19:04'
      fill_in 'end_at_5', with: '19:05'
      fill_in 'end_at_6', with: '19:06'
      find_by_id('end_at_6').native.send_keys :tab
      expect(find_by_id('end_at_1').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 1).end_at)
      expect(find_by_id('end_at_2').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 2).end_at)
      expect(find_by_id('end_at_3').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 3).end_at)
      expect(find_by_id('end_at_4').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 4).end_at)
      expect(find_by_id('end_at_5').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 5).end_at)
      expect(find_by_id('end_at_6').value).to eq I18n.l(begin_end_times.reload.find_by(period_index: 6).end_at)
    end
  end

  describe '予定の編集' do
    before :each do
      driven_by :remote_chrome
      @term = create_normal_term_with_teacher_and_student(1, 1)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '開講が表示・更新される' do
      visit timetables_path
    end
  end
end
