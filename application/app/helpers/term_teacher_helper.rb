module TermTeacherHelper
  def options_for_select_teacher_id(room, term)
    plucked_teachers = room.teachers.active.pluck(:name, :id)
    plucked_term_teachers = term.term_teachers.ordered.joins(:teacher).pluck('teachers.name',
                                                                             :teacher_id)
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

  def term_teacher_schedule_table_cell(tutorial_pieces, term_groups, timetables, date_index, period_index)
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
                class: term_teacher_schedule_table_cell_class(timetable, term_group, filtered_tutorial_pieces)) do
      content_tag(:div, class: 'min-height-60 d-flex flex-column justify-content-center') do
        term_teacher_schedule_table_cell_inner(timetable, filtered_tutorial_pieces)
      end
    end
  end

  def term_teacher_schedule_table_cell_class(timetable, term_group, tutorial_pieces)
    if timetable.is_closed
      'align-middle bg-secondary'
    elsif !timetable.is_vacant
      'align-middle bg-secondary'
    elsif term_group.nil? && timetable.group_name.present?
      'align-middle bg-secondary'
    elsif term_group.present? && timetable.group_name.present?
      'align-middle bg-warning-light'
    elsif tutorial_pieces.present?
      'align-middle bg-warning-light'
    else
      'align-middle'
    end
  end

  def term_teacher_schedule_table_cell_inner(timetable, tutorial_pieces)
    if timetable.is_closed
      '休講'
    elsif timetable.group_name.present?
      timetable.group_name
    else
      tutorial_pieces.each do |tutorial_piece|
        concat(
          content_tag(:div) do
            "#{tutorial_piece.student_name}（#{tutorial_piece.tutorial_name}）"
          end,
        )
      end
    end
  end
end
