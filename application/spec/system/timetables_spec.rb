# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '時間割りの編集ページ', type: :system do
  describe '開始時刻と終了時刻の表示と更新' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(1, 1)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '開始時刻が表示・更新される' do
      begin_end_time = @term.begin_end_times.find_by(period_index: 1)
      before = I18n.l(begin_end_time.begin_at)
      after = I18n.l(begin_end_time.begin_at + 5.minutes)

      visit timetables_path
      expect(find_by_id('begin_at_1').value).to eq before
      fill_in 'begin_at_1', with: after
      find_by_id('begin_at_1').native.send_keys :tab
      wait_for_ajax
      expect(find_by_id('begin_at_1').value).to eq after
      expect(I18n.l(begin_end_time.reload.begin_at)).to eq after
    end

    it '終了時刻が表示・更新される' do
      begin_end_time = @term.begin_end_times.find_by(period_index: 1)
      before = I18n.l(begin_end_time.end_at)
      after = I18n.l(begin_end_time.end_at + 5.minutes)

      visit timetables_path
      expect(find_by_id('end_at_1').value).to eq before
      fill_in 'end_at_1', with: after
      find_by_id('end_at_1').native.send_keys :tab
      wait_for_ajax
      expect(find_by_id('end_at_1').value).to eq after
      expect(I18n.l(begin_end_time.reload.end_at)).to eq after
    end
  end

  describe '個別授業、集団授業の追加' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(1, 1)
      @room = @term.room
      @tutorial = FactoryBot.create(:tutorial, room: @room)
      @group = FactoryBot.create(:group, room: @room)
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it 'モーダルの表示・非表示が切り替わる' do
      visit timetables_path
      expect(page).to have_no_content '個別科目をこのスケジュールに追加する'
      click_on '新規個別'
      expect(page).to have_content '個別科目をこのスケジュールに追加する'
      click_on '戻る'
      expect(page).to have_no_content '個別科目をこのスケジュールに追加する'
      expect(page).to have_no_content '集団科目をこのスケジュールに追加する'
      click_on '新規集団'
      expect(page).to have_content '集団科目をこのスケジュールに追加する'
      click_on '戻る'
      expect(page).to have_no_content '集団科目をこのスケジュールに追加する'
    end

    it '個別科目がスケジュールに追加される' do
      visit timetables_path
      click_on '新規個別'
      expect(page).to have_content '個別科目をこのスケジュールに追加する'
      expect(page).to have_select('term_tutorial_tutorial_id', selected: '選択してください')
      select @tutorial.name, from: 'term_tutorial_tutorial_id'
      click_on '保存'
      @term.reload
      expect(page).to have_no_content '個別科目をこのスケジュールに追加する'
      expect(@term.term_tutorials.count).to eq(6)
    end

    it '集団科目がスケジュールに追加される' do
      visit timetables_path
      click_on '新規集団'
      expect(page).to have_content '集団科目をこのスケジュールに追加する'
      expect(page).to have_select('term_group_group_id', selected: '選択してください')
      select @group.name, from: 'term_group_group_id'
      click_on '保存'
      @term.reload
      expect(page).to have_no_content '集団科目をこのスケジュールに追加する'
      expect(@term.term_groups.count).to eq(3)
    end
  end

  describe '集団授業、休講日程の表示と更新' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(1, 1)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '日程が表示・更新される' do
      timetable = @term.timetables.find_by(date_index: 1, period_index: 1)
      term_group = @term.term_groups.first
      timetable_id = "select_status_#{timetable.id}"

      visit timetables_path
      expect(find_by_id(timetable_id).value).to eq('0')
      select '休講', from: timetable_id
      wait_for_ajax
      expect(find_by_id(timetable_id).value).to eq('-1')
      expect(timetable.reload.is_closed).to eq(true)
      expect(timetable.reload.term_group_id).to eq(nil)
      expect(page).to have_selector 'td.bg-secondary'
      expect(page).to have_no_selector 'td.bg-warning-light'
      select term_group.group.name, from: timetable_id
      wait_for_ajax
      expect(find_by_id(timetable_id).value).to eq(term_group.id.to_s)
      expect(timetable.reload.is_closed).to eq(false)
      expect(timetable.reload.term_group_id).to eq(term_group.id)
      expect(page).to have_no_selector 'td.bg-secondary'
      expect(page).to have_selector 'td.bg-warning-light'
      select '開講', from: timetable_id
      wait_for_ajax
      expect(find_by_id(timetable_id).value).to eq('0')
      expect(timetable.reload.is_closed).to eq(false)
      expect(timetable.reload.term_group_id).to eq(nil)
      expect(page).to have_no_selector 'td.bg-secondary'
      expect(page).to have_no_selector 'td.bg-warning-light'
    end
  end

  describe '集団授業、休講日程の表示と更新' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(1, 1)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it 'モーダルの表示・非表示が切り替わる' do
      visit timetables_path
      expect(page).to have_no_content '集団担任を変更する'
      click_on '集団担任'
      expect(page).to have_content '集団担任を変更する'
      click_on '戻る'
      expect(page).to have_no_content '集団担任を変更する'
    end

    it '集団担任が更新される' do
      term_teacher = @term.term_teachers.first
      term_group = @term.term_groups.first

      visit timetables_path
      click_on '集団担任'
      expect(page).to have_no_content '集団担任を変更する'
      within "#edit_term_group_#{term_group.id}" do
        expect(page).to have_select("multiselect-#{term_group.id}")
        select term_teacher.teacher.name, from: "multiselect-#{term_group.id}"
        click_on '保存'
      end
      expect(page).to have_no_content '集団担任を変更する'
      expect(term_group.reload.term_teacher_ids).to eq([term_teacher.id])
    end
  end
end
