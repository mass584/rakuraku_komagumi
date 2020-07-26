module ContractHelper
  def select_tag_count(contract)
    select = (1..10).reduce({ '受講しない' => 0 }) do |accu, item|
      accu.merge({ "#{item}回" => item })
    end
    select_tag(
      :count,
      options_for_select(select, selected: contract.count),
      id: "select_count_#{contract.id}",
      class: 'form-control form-control-sm',
      onchange: 'cb_select(event);',
    )
  end

  def select_tag_teacher_term_id(contract)
    teachers = contract.term.teachers.joins(:subjects).where(
      'subjects.id': contract.subject_term.subject.id,
    ).or(
      contract.term.teachers.joins(:subjects).where(id: contract.count),
    ).distinct
    options = options_from_collection_for_select(
                teachers, :id, :name, contract.teacher_term_id
              )
    select_tag(
      :teacher_term_id,
      options,
      include_blank: '担任を選択',
      id: "select_teacher_term_id_#{contract.id}",
      class: 'form-control form-control-sm',
      onchange: 'cb_select(event);',
    )
  end

  def contract_updator(contract)
    is_exist = contract.teacher_term_id.present? || contract.count.positive?
    td_class = is_exist ? 'align-middle mw-200 bg-active' : 'align-middle mw-200'
    content_tag(:td, class: td_class) do
      concat(
        content_tag(:div,
                    'data-id' => contract.id,
                    'data-count' => contract.count,
                    'data-teacher_term_id' => contract.teacher_term_id,
                    'class' => 'row align-items-center') do
          concat(
            content_tag(:div, class: 'col-9 pl-4 pr-2') do
              concat select_tag_count(contract)
              concat select_tag_teacher_term_id(contract)
            end,
          )
          concat(
            content_tag(:div, class: 'col-3 pl-0 pr-4 d-flex align-items-end') do
              concat button_tag(
                '消',
                id: "button_delete_#{contract.id}",
                class: %w[btn btn-sm btn-danger],
                onclick: 'cb_button(event);',
              )
            end,
          )
        end,
      )
    end
  end
end
