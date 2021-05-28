module TermStudentHelper
  def options_for_select_student_id(room, term)
    plucked_students = room.students.active.pluck(:name, :id)
    plucked_term_students = term.term_students.ordered.joins(:student).pluck('students.name',
                                                                             :student_id)
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

  def term_student_schedule_table_cell(tutorial_pieces, term_groups, timetables, date_index, period_index)
    timetable = timetables.find do |item|
      item.date_index == date_index && item.period_index == period_index
    end
    term_group = term_groups.find do |item|
      item.date_index == date_index && item.period_index == period_index
    end
    filtered_tutorial_pieces = tutorial_pieces.filter do |tutorial_piece|
      tutorial_piece.date_index == date_index && tutorial_piece.period_index == period_index
    end
    content_tag(:td,
                class: term_student_schedule_table_cell_class(timetable, term_group, filtered_tutorial_pieces)) do
      content_tag(:small, class: 'min-height-40 d-flex flex-column justify-content-center') do
        term_student_schedule_table_cell_inner(timetable, filtered_tutorial_pieces)
      end
    end
  end

  def term_student_schedule_table_cell_class(timetable, term_group, tutorial_pieces)
    if tutorial_pieces.present?
      'align-middle bg-warning-light'
    elsif term_group.present? && timetable.group_name.present?
      'align-middle bg-warning-light'
    elsif timetable.is_closed
      'align-middle bg-secondary'
    elsif !timetable.is_vacant
      'align-middle bg-secondary'
    elsif term_group.nil? && timetable.group_name.present?
      'align-middle bg-secondary'
    else
      'align-middle'
    end
  end

  def term_student_schedule_table_cell_inner(timetable, tutorial_pieces)
    if timetable.present? && timetable.is_closed
      '休講'
    elsif timetable.present? && timetable.group_name.present?
      timetable.group_name
    elsif !timetable.is_vacant
      '出席不可'
    else
      tutorial_pieces.each do |tutorial_piece|
        concat(
          content_tag(:div) do
            "#{tutorial_piece.tutorial_name}（#{tutorial_piece.teacher_name}）"
          end,
        )
      end
    end
  end
end
