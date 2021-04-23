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
      teacher_name = @teacher.name
      select teacher_name, from: 'term_teacher_teacher_id'
      click_on '保存'
      expect(page).to have_content teacher_name
    end

    it 'エラーが表示される' do
      visit term_teachers_path
      click_on '新規'
      click_on '保存'
      expect(page).to have_content '講師を入力してください'
    end
  end

  describe '講師のステータス編集' do
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
    end
  end

  describe '講師のマルバツ表編集' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(1, 0)
      @room = @term.room
      @teacher_vacancy =
        TeacherVacancy.joins(:timetable).find_by(
          'timetables.date_index': 1,
          'timetables.period_index': 1,
        )
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it 'マルバツ表が更新される' do
      visit term_teachers_path
      find('a[href$="/vacancy"]').click
      expect(page).to have_no_content 'NG'
      find('#button_1_1').click
      expect(page).to have_content 'NG'
      expect(@teacher_vacancy.reload.is_vacant).to eq(false)
    end
  end

  describe '講師の予定表表示' do
    before :each do
      @term = create_normal_term_with_schedule
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '予定表が表示される' do
      visit term_teachers_path
      find('a[href$="/schedule"]').click
      tutorial_name = @term.term_tutorials.first.tutorial.name
      student_name = @term.term_students.first.student.name
      group_name = @term.term_groups.first.group.name
      expect(page).to have_content "#{student_name}（#{tutorial_name}）"
      expect(page).to have_content group_name
    end
  end
end
