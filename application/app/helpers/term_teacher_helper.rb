module TermTeacherHelper
  def options_for_select_teacher_id(room, term)
    plucked_teachers = room.teachers.active.pluck(:name, :id) 
    plucked_term_teachers = term.term_teachers.ordered.joins(:teacher).pluck( 'teachers.name', :teacher_id)
    plucked_teachers - plucked_term_teachers
  end

  def teacher_vacancy_button(term_teacher, teacher_vacancies, date_index, period_index)
    teacher_vacancy = teacher_vacancies.find do |item|
      item.date_index == date_index && item.period_index == period_index
    end
    content_tag(:div, 'data-id' => teacher_vacancy.id) do
      button_tag(
        teacher_vacancy.is_vacant ? 'OK' : 'NG',
        class: teacher_vacancy.is_vacant ? 'btn btn-primary' : 'btn btn-danger',
        id: "button_#{date_index}_#{period_index}",
        disabled: term_teacher.fixed?,
      )
    end
  end

  def schedule_cell(pieces)
    content_tag(:div) do
      pieces.each do |piece|
        concat(
          content_tag(:div) do
            "#{piece.contract.student_term.student.name}
            （#{piece.contract.subject_term.subject.name}）"
          end,
        )
      end
    end
  end
end
