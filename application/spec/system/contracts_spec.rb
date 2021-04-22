# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '受講科目の編集ページ', type: :system do
  describe '個別科目の表示と更新' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(1, 1)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '個別科目の受講数が表示・更新される' do
      tutorial_contract = @term.tutorial_contracts.first
      select_piece_count_id = "select_piece_count_#{tutorial_contract.id}"

      visit contracts_path
      expect(page).to have_select(select_piece_count_id, selected: '受講しない')
      select '1回', from: select_piece_count_id
      expect(page).to have_selector 'td.bg-warning-light'
      expect(page).to have_select(select_piece_count_id, selected: '1回')
      expect(tutorial_contract.reload.piece_count).to eq(1)
      select '受講しない', from: select_piece_count_id
      expect(page).to have_no_selector 'td.bg-warning-light'
      expect(page).to have_select(select_piece_count_id, selected: '受講しない')
      expect(tutorial_contract.reload.piece_count).to eq(0)
    end

    it '個別科目の担任が表示・更新される' do
      tutorial_contract = @term.tutorial_contracts.first
      term_teacher = @term.term_teachers.first
      select_term_teacher_id = "select_term_teacher_id_#{tutorial_contract.id}"

      visit contracts_path
      expect(page).to have_select(select_term_teacher_id, selected: '担任を選択')
      select term_teacher.teacher.name, from: select_term_teacher_id
      expect(page).to have_selector 'td.bg-warning-light'
      expect(page).to have_select(select_term_teacher_id, selected: term_teacher.teacher.name)
      expect(tutorial_contract.reload.term_teacher_id).to eq(term_teacher.id)
      select '担任を選択', from: select_term_teacher_id
      expect(page).to have_no_selector 'td.bg-warning-light'
      expect(page).to have_select(select_term_teacher_id, selected: '担任を選択')
      expect(tutorial_contract.reload.term_teacher_id).to eq(nil)
    end

    it '個別科目の受講数と担任がリセットされる' do
      tutorial_contract = @term.tutorial_contracts.first
      term_teacher = @term.term_teachers.first
      select_piece_count_id = "select_piece_count_#{tutorial_contract.id}"
      select_term_teacher_id = "select_term_teacher_id_#{tutorial_contract.id}"

      visit contracts_path
      expect(page).to have_select(select_piece_count_id, selected: '受講しない')
      expect(page).to have_select(select_term_teacher_id, selected: '担任を選択')
      # 受講数と担任をセットする 
      select '1回', from: select_piece_count_id
      select term_teacher.teacher.name, from: select_term_teacher_id
      expect(page).to have_selector 'td.bg-warning-light'
      expect(page).to have_select(select_piece_count_id, selected: '1回')
      expect(page).to have_select(select_term_teacher_id, selected: term_teacher.teacher.name)
      expect(tutorial_contract.reload.piece_count).to eq(1)
      expect(tutorial_contract.reload.term_teacher_id).to eq(term_teacher.id)
      # 受講数と担任をリセットする 
      page.accept_confirm do
        find_by_id("button_delete_#{tutorial_contract.id}").click
      end
      expect(page).to have_no_selector 'td.bg-warning-light'
      expect(page).to have_select(select_piece_count_id, selected: '受講しない')
      expect(page).to have_select(select_term_teacher_id, selected: '担任を選択')
      expect(tutorial_contract.reload.piece_count).to eq(0)
      expect(tutorial_contract.reload.term_teacher_id).to eq(nil)
    end
  end

  describe '集団科目の表示と更新' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(1, 1)
      @room = @term.room
      stub_authenticate_user
      stub_current_room @room
      stub_current_term @term
    end

    it '集団科目の契約可否が表示・更新される' do
      group_contract = @term.group_contracts.first
      select_id = "select_is_contracted_#{group_contract.id}"

      visit contracts_path
      expect(page).to have_select(select_id, selected: '受講しない')
      select '受講する', from: select_id
      expect(page).to have_selector 'td.bg-warning-light'
      expect(page).to have_select(select_id, selected: '受講する')
      expect(group_contract.reload.is_contracted).to eq(true)
      select '受講しない', from: select_id
      expect(page).to have_no_selector 'td.bg-warning-light'
      expect(page).to have_select(select_id, selected: '受講しない')
      expect(group_contract.reload.is_contracted).to eq(false)
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
      visit contracts_path
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
      visit contracts_path
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
      visit contracts_path
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
end
