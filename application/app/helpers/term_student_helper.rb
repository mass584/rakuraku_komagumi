module TermStudentHelper
  def options_for_select_student_id(room, term)
    plucked_students = room.students.active.pluck(:name, :id) 
    plucked_term_students = term.term_students.ordered.joins(:student).pluck( 'students.name', :student_id)
    plucked_students - plucked_term_students
  end

  def student_vacancy_button(term_student, student_vacancies, date_index, period_index)
    student_vacancy = student_vacancies.find do |item|
      item.date_index == date_index && item.period_index == period_index
    end
    content_tag(:div, 'data-id' => student_vacancy.id) do
      button_tag(
        student_vacancy.is_vacant ? 'OK' : 'NG',
        class: student_vacancy.is_vacant ? 'btn btn-primary' : 'btn btn-danger',
        id: "button_#{date_index}_#{period_index}",
        disabled: term_student.fixed?,
      )
    end
  end

  def schedule_cell(pieces)
    content_tag(:div) do
      pieces.each do |piece|
        concat(
          content_tag(:div) do
            "#{piece.contract.subject_term.subject.name}
            （#{piece.seat.teacher_term.teacher.name}）"
          end,
        )
      end
    end
  end
end
