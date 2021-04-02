require 'rails_helper'

RSpec.describe StudentVacancy, type: :model do
  describe '予定が入っていないかどうかのバリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 1)
      term_teacher = term.term_teachers.first
      term_student = term.term_students.first
      tutorial_contract = term.tutorial_contracts.first
      tutorial_contract.update(piece_count: 1, term_teacher_id: term_teacher.id)
      piece = tutorial_contract.tutorial_pieces.first
      seat = term.seats.first
      piece.update(seat_id: seat.id)
      @student_vacancy = seat.timetable.student_vacancies.find_by(term_student_id: term_student.id)
      @student_vacancy.update(is_vacant: false)
    end

    it '配置済みのコマがある場合はupdate失敗' do
      expect(@student_vacancy.update(is_vacant: false)).to eq(false)
      expect(@student_vacancy.reload.is_vacant).to eq(true)
      expect(@student_vacancy.errors.full_messages).to include('生徒の予定がすでに埋まっています')
    end
  end
end
