module ContractHelper
  def select_tag_count(default)
    select = [['', 0]].concat([*1..20])
    select_tag(
      :count,
      options_for_select(select, default),
      id: 'select_count',
      class: 'form-control form-control-sm',
    )
  end

  def select_tag_teacher_id(default, contract)
    teachers = contract.term.teachers.joins(:subjects).where('subjects.id': contract.subject_id)
                       .or(contract.term.teachers.joins(:subjects).where(id: default))
                       .distinct
    content = content_tag(:option, '', 'value' => nil) +
              options_from_collection_for_select(teachers, :id, :name, default)
    select_tag(
      :teacher_id, content,
      id: 'select_teacher',
      class: 'form-control form-control-sm'
    )
  end

  def contract_updator(contract)
    is_exist = contract.teacher_id.present? || contract.count.positive?
    td_class = is_exist ? 'align-middle bg-active' : 'align-middle'
    content_tag(:td, class: td_class) do
      concat(
        content_tag(:div,
                    'data-id' => contract.id,
                    'data-count' => contract.count,
                    'data-teacher_id' => contract.teacher_id,
                    'class' => 'row') do
          concat(
            content_tag(:div, class: 'col-9 pl-4 pr-2') do
              concat content_tag(:span, '受講回数', class: 'label')
              concat select_tag_count(contract.count)
              concat content_tag(:span, '担当講師', class: 'label')
              concat select_tag_teacher_id(contract.teacher_id, contract)
            end,
          )
          concat(
            content_tag(:div, class: 'col-3 pl-0 pr-4 d-flex align-items-end') do
              concat button_tag('削除', 'class' => %w[btn btn-sm btn-danger], 'id' => 'button_delete')
            end,
          )
        end,
      )
    end
  end
end
