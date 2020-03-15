module ClassnumberHelper
  def select_tag_number(default)
    select = [['', 0]].concat([*1..20])
    select_tag(
      :number,
      options_for_select(select, default),
      id: 'select_number',
      class: 'form-control form-control-sm'
    )
  end

  def select_tag_teacher_id(classnumber)
    teacher_default = classnumber.teacher_id
    teacher_list = classnumber.schedulemaster.teachers.joins(:subjects).where('subjects.id': classnumber.subject_id)
                   .or(classnumber.schedulemaster.teachers.joins(:subjects).where(id: teacher_default))
                   .distinct
    content = content_tag(:option, '', 'value' => nil) +
              options_from_collection_for_select(teacher_list, :id, :name, teacher_default)
    select_tag(
      :teacher_id, content,
      id: 'select_teacher',
      class: 'form-control form-control-sm'
    )
  end

  def classnumber_updator(classnumber)
    lesson_exist = classnumber.teacher_id.present? || classnumber.number.positive?
    td_class = lesson_exist ? 'align-middle bg-active' : 'align-middle'
    content_tag(:td, class: td_class) do
      concat (
        content_tag(:div,
                    'data-id' => classnumber.id,
                    'data-number' => classnumber.number,
                    'data-teacher_id' => classnumber.teacher_id,
                    'class' => 'row') do
          concat (
            content_tag(:div, class: 'col-9 pl-4 pr-2') do
              concat content_tag(:span, '受講回数', class: 'label')
              concat select_tag_number(classnumber.number)
              concat content_tag(:span, '担当講師', class: 'label')
              concat select_tag_teacher_id(classnumber)
            end
          )
          concat (
            content_tag(:div, class: 'col-3 pl-0 pr-4 d-flex align-items-end') do
              concat button_tag('削除', 'class' => ['btn', 'btn-sm', 'btn-danger'], 'id' => 'button_delete')
            end
          )
        end
      )
    end
  end
end
