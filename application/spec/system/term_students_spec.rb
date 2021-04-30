# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '生徒の編集ページ', type: :system do
  describe '生徒の追加' do
    before :each do
      @term = create_normal_term
      @room = @term.room
      @student = FactoryBot.create(:student, room: @room)
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '生徒が新規追加される' do
      visit term_students_path
      click_on '新規'
      student_name = @student.name
      student_school_grade = @student.school_grade_i18n
      select student_name, from: 'term_student_student_id'
      click_on '保存'
      expect(page).to have_content student_name
      expect(page).to have_content student_school_grade
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
    end
  end

  describe '生徒のマルバツ表編集' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(0, 1)
      @room = @term.room
      @student_vacancy =
        StudentVacancy.joins(:timetable).find_by(
          'timetables.date_index': 1,
          'timetables.period_index': 1,
        )
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it 'マルバツ表が更新される' do
      visit term_students_path
      find('a[href$="/vacancy"]').click
      expect(page).to have_no_content 'NG'
      find('#button_1_1').click
      expect(page).to have_content 'NG'
      expect(@student_vacancy.reload.is_vacant).to eq(false)
    end
  end

  describe '生徒の予定表表示' do
    before :each do
      @term = create_normal_term_with_schedule
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '予定表が表示される' do
      visit term_students_path
      within('table') do
        find('a[href$="/schedule"]').click
      end
      tutorial_name = @term.term_tutorials.first.tutorial.name
      teacher_name = @term.term_teachers.first.teacher.name
      group_name = @term.term_groups.first.group.name
      expect(page).to have_content "#{tutorial_name}（#{teacher_name}）"
      expect(page).to have_content group_name
    end
  end
end
