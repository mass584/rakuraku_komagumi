# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '全体予定の編集ページ', type: :system do
  describe '表ヘッダー部の機能のテスト' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(6, 15)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '講師の表示順が変更される' do
      term_teacher = @term.term_teachers.rank(:row_order).first
      visit tutorial_pieces_path
      expect(page).to have_selector '#modal-loader'
      expect(page).to have_no_selector '#modal-loader'
      expect(term_teacher.row_order_rank).to eq(0)
      within "#stand_by_#{term_teacher.id}" do
        find_by_id("right_button_#{term_teacher.id}").click
      end
      expect(page).to have_selector '#modal-loader'
      expect(page).to have_no_selector '#modal-loader'
      expect(term_teacher.reload.row_order_rank).to eq(1)
      within "#stand_by_#{term_teacher.id}" do
        find_by_id("left_button_#{term_teacher.id}").click
      end
      expect(page).to have_selector '#modal-loader'
      expect(page).to have_no_selector '#modal-loader'
      expect(term_teacher.reload.row_order_rank).to eq(0)
    end

    it 'コマを選択するとコマが表示される' do
      term_teacher = @term.term_teachers.rank(:row_order).first
      term_student = @term.term_students.first
      term_tutorial = @term.term_tutorials.first
      tutorial_contract = @term.tutorial_contracts.find_by(
        term_student: term_student,
        term_tutorial: term_tutorial,
      )
      term_teacher.update(vacancy_status: 'fixed')
      term_student.update(vacancy_status: 'fixed')
      tutorial_contract.update(term_teacher: term_teacher, piece_count: 1)
      student = tutorial_contract.term_student.student
      tutorial = tutorial_contract.term_tutorial.tutorial
      tutorial_piece_display_text = "#{student.school_grade_i18n} #{student.name} #{tutorial.short_name}"
      visit tutorial_pieces_path
      expect(page).to have_selector '#modal-loader'
      expect(page).to have_no_selector '#modal-loader'
      within "#stand_by_#{term_teacher.id}" do
        select tutorial_piece_display_text, from: "tutorial_piece_select_#{term_teacher.id}"
        within "#stand_by_tutorial_position_#{term_teacher.id}" do
          expect(page).to have_content tutorial_piece_display_text
        end
      end
    end
  end

  describe '全体予定の表示' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(6, 15)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
      # 情報の設定
      term_teacher = @term.term_teachers.first
      term_student = @term.term_students.first
      term_tutorial = @term.term_tutorials.first
      term_group = @term.term_groups.first
      tutorial_timetable = @term.timetables.find_by(date_index: 1, period_index: 1)
      tutorial_seat = tutorial_timetable.seats.first
      group_timetable = @term.timetables.find_by(date_index: 2, period_index: 1)
      term_teacher.update(vacancy_status: 'fixed')
      term_student.update(vacancy_status: 'fixed')
      # 集団科目の設定
      group_contract = @term.group_contracts.find_by(
        term_student: term_student,
        term_group: term_group,
      )
      group_contract.update(is_contracted: true)
      term_group.term_group_term_teachers.create(term_teacher: term_teacher)
      group_timetable.update(term_group: term_group)
      # 個別科目の設定
      tutorial_contract = @term.tutorial_contracts.find_by(
        term_student: term_student,
        term_tutorial: term_tutorial,
      )
      tutorial_contract.update(term_teacher: term_teacher, piece_count: 1)
      tutorial_seat.update(term_teacher: term_teacher)
      tutorial_piece = tutorial_contract.tutorial_pieces.first
      tutorial_piece.update(seat: tutorial_seat)
    end

    it '個別コマ、集団コマが表示される' do
      # ページの表示
      visit tutorial_pieces_path
      expect(page).to have_selector '#modal-loader'
      expect(page).to have_no_selector '#modal-loader'
      student = tutorial_contract.term_student.student
      tutorial = tutorial_contract.term_tutorial.tutorial
      tutorial_piece_display_text = "#{student.school_grade_i18n} #{student.name} #{tutorial.short_name}"
      group = term_group.group
      group_piece_display_text = group.name
      expect(page).to have_content tutorial_piece_display_text
      expect(page).to have_content group_piece_display_text
    end
  end
end
