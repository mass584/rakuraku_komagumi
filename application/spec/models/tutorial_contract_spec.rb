require 'rails_helper'

RSpec.describe TutorialContract, type: :model do
  describe 'TutorialPieceレコードの追加と削除' do
    before :each do
      @term = create_normal_term_with_teacher_and_student(0, 1)
      @first = @term.tutorial_contracts.first
      @second = @term.tutorial_contracts.second
    end

    context 'コマ数を増やした時' do
      it 'TutorialPieceレコードが追加される' do
        expect(TutorialPiece.all.count).to eq(0)
        @first.update(piece_count: 4)
        expect(TutorialPiece.all.count).to eq(4)
        @second.update(piece_count: 4)
        expect(TutorialPiece.all.count).to eq(8)
      end
    end

    context 'コマ数を減らした時' do
      it 'TutorialPieceレコードが削除される' do
        @first.update(piece_count: 4)
        @second.update(piece_count: 4)
        expect(TutorialPiece.all.count).to eq(8)
        @first.update(piece_count: 0)
        expect(TutorialPiece.all.count).to eq(4)
        @second.update(piece_count: 0)
        expect(TutorialPiece.all.count).to eq(0)
      end
    end
  end

  describe 'term_teacher_idの更新時のバリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 1)
      @term_teacher = term.term_teachers.first
      @tutorial_contract = term.tutorial_contracts.first
      @tutorial_contract.update(piece_count: 1, term_teacher_id: @term_teacher.id)
      @piece = @tutorial_contract.tutorial_pieces.first
      @seat = term.seats.first
    end

    context 'term_teacher_idの変更時' do
      it '配置済みのコマがない場合はupdate成功' do
        expect(@tutorial_contract.update(term_teacher_id: nil)).to eq(true)
        expect(@tutorial_contract.reload.term_teacher_id).to eq(nil)
      end

      it '配置済みのコマがある場合はupdate失敗' do
        @piece.update(seat_id: @seat.id)
        expect(@tutorial_contract.update(term_teacher_id: nil)).to eq(false)
        expect(@tutorial_contract.reload.term_teacher_id).to eq(@term_teacher.id)
        expect(@tutorial_contract.errors.full_messages).to include('配置済みのコマがあるため担任を変更できません')
      end
    end
  end

  describe 'piece_countの更新時のバリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 1)
      @term_teacher = term.term_teachers.first
      @tutorial_contract = term.tutorial_contracts.first
      @tutorial_contract.update(piece_count: 2, term_teacher_id: @term_teacher.id)
      @piece = @tutorial_contract.tutorial_pieces.first
      @seat = term.seats.first
    end

    context 'piece_countの変更時' do
      it '配置済みのコマ数を下回らない場合はupdate成功' do
        @piece.update(seat_id: @seat.id)
        expect(@tutorial_contract.update(piece_count: 1)).to eq(true)
        expect(@tutorial_contract.reload.piece_count).to eq(1)
      end

      it '配置済みのコマ数を下回る場合はupdate失敗' do
        @piece.update(seat_id: @seat.id)
        expect(@tutorial_contract.update(piece_count: 0)).to eq(false)
        expect(@tutorial_contract.reload.piece_count).to eq(2)
        expect(@tutorial_contract.errors.full_messages).to include('配置済みのコマを未決定に戻す必要があります')
      end
    end
  end
end
