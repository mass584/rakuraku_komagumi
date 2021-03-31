require 'rails_helper'

RSpec.describe TeacherVacancy, type: :model do
  describe '予定が入っていないかどうかのバリデーションの検証' do
    before :each do
      term = create_normal_term_with_teacher_and_student(1, 0)
      term_teacher = term.term_teachers.first
      seat = term.seats.first
      seat.update(term_teacher_id: term_teacher.id)
      @teacher_vacancy = seat.timetable.teacher_vacancies.find_by(term_teacher_id: term_teacher.id)
      @teacher_vacancy.update(is_vacant: false)
    end

    it '配置済みのコマがある場合はupdate失敗' do
      expect(@teacher_vacancy.update(is_vacant: false)).to eq(false)
      expect(@teacher_vacancy.reload.is_vacant).to eq(true)
      expect(@teacher_vacancy.errors.full_messages).to include('講師の予定がすでに埋まっています')
    end
  end
end
