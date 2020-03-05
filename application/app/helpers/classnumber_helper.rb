module ClassnumberHelper
  def select_tag_class_number(default)
    select = [*1..25].unshift(['', 0])
    select_tag(
      :number, options_for_select(select, default),
      id: 'select_number',
      style: 'width: 120px;'
    )
  end

  def select_tag_group_lesson_teacher(schedulemaster, subject_id)
    subject_name = schedulemaster.subjects.find(subject_id).name
    teacher_candidate = schedulemaster.teachers.joins(:subjects).where('subjects.id': subject_id)
    teacher_id = schedulemaster.subject_schedulemaster_mappings.find_by(subject_id: subject_id).teacher_id
    content = content_tag(:option, '', 'value' => 0) +
              options_from_collection_for_select(teacher_candidate, :id, :fullname, teacher_id)
    content_tag(:div, 'data-subject_id' => subject_id, 'data-teacher_id' => teacher_id) do
      concat(subject_name)
      concat(tag.br)
      concat('担当講師：')
      concat(select_tag(
               :teacher_id, content,
               id: 'select_group_teacher',
               style: 'width: 120px;'
             ))
    end
  end

  def select_tag_individual_lesson_teacher(schedulemaster, student_id, subject_id)
    teacher_default = schedulemaster.classnumbers.find_by(subject_id: subject_id, student_id: student_id).teacher_id
    teacher_list =
      schedulemaster.teachers.joins(:subjects).where('subjects.id': subject_id)
                    .or(schedulemaster.teachers.joins(:subjects).where(id: teacher_default))
                    .distinct
    content = content_tag(:option, '', 'value' => 0) +
              options_from_collection_for_select(teacher_list, :id, :fullname, teacher_default)
    select_tag(
      :teacher_id, content,
      id: 'select_teacher',
      style: 'width: 120px;'
    )
  end

  def group_lesson_updator(classnumber)
    content = check_box_tag(:number, 1, classnumber.number.nonzero?, 'id' => 'check_group')
    content_tag(
      :div, content,
      'data-id' => classnumber.id,
      'data-number' => classnumber.number
    )
  end

  def individual_lesson_updator(schedulemaster, classnumber)
    content_tag(:div,
                'data-id' => classnumber.id,
                'data-number' => classnumber.number,
                'data-teacher_id' => classnumber.teacher_id) do
      concat('授業回数 : ')
      concat(select_tag_class_number(classnumber.number))
      concat(tag.br)
      concat('担当講師 : ')
      concat(select_tag_individual_lesson_teacher(schedulemaster, classnumber.student_id, classnumber.subject_id))
      concat(button_tag(
               '削除',
               'class' => ['btn', 'btn-xs', 'btn-danger'],
               'id' => 'button_delete',
               'style' => 'float: right;',
             ))
    end
  end
end
