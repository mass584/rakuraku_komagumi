require 'rails_helper'

RSpec.describe TutorialPiece, type: :model do
  describe 'seat.term_teacher_idの同時変更' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 2)
      tutorial_contract_first = term.tutorial_contracts.find_by(term_student_id: term.term_students.first.id)
      tutorial_contract_second = term.tutorial_contracts.find_by(term_student_id: term.term_students.second.id)
      tutorial_contract_first.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      tutorial_contract_second.update(piece_count: 1, term_teacher_id: term.term_teachers.first.id)
      @first = tutorial_contract_first.tutorial_pieces.first
      @second = tutorial_contract_second.tutorial_pieces.first
      @seat = term.seats.all.first
    end

    context '座席に１人目を割り当てた時' do
      it 'seat.term_teacher_idが更新される' do
        @first.update(seat_id: @seat.id)
        expect(@seat.reload.term_teacher_id).to eq(@first.tutorial_contract.term_teacher_id)
        @second.update(seat_id: @seat.id)
        expect(@seat.reload.term_teacher_id).to eq(@first.tutorial_contract.term_teacher_id)
      end
    end

    context '座席から割り当てを解除した時' do
      it 'seat.term_teacher_idが更新される' do
        @first.update(seat_id: @seat.id)
        @second.update(seat_id: @seat.id)
        @first.update(seat_id: nil)
        expect(@seat.reload.term_teacher_id).to eq(@first.tutorial_contract.term_teacher_id)
        @second.update(seat_id: nil)
        expect(@seat.reload.term_teacher_id).to eq(nil)
      end
    end
  end
end
