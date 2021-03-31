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
end
