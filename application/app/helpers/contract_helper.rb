module ContractHelper
  def select_tag_piece_count(tutorial_contract)
    select = (1..10).reduce({ '受講しない' => 0 }) do |accu, item|
      accu.merge({ "#{item}回" => item })
    end
    select_tag(
      :piece_count,
      options_for_select(select, selected: tutorial_contract.piece_count),
      id: "select_piece_count_#{tutorial_contract.id}",
      class: 'form-control form-control-sm',
    )
  end

  def select_tag_term_teacher_id(tutorial_contract, term_teachers)
    select_tag(
      :term_teacher_id,
      options_from_collection_for_select(term_teachers, :id, :name, tutorial_contract.term_teacher_id),
      include_blank: '担任を選択',
      id: "select_term_teacher_id_#{tutorial_contract.id}",
      class: 'form-control form-control-sm',
    )
  end

  def tutorial_contract_table_cell(tutorial_contracts, term_teachers, term_student, term_tutorial)
    tutorial_contract = tutorial_contracts.find do |item|
      item.term_student_id == term_student.id && item.term_tutorial_id == term_tutorial.id
    end
    td_class = tutorial_contract.is_active? ? 'align-middle min-width-200 bg-warning-light' : 'align-middle min-width-200'
    content_tag(:td, class: td_class) do
      content_tag(:div,
                  'data-id' => tutorial_contract.id,
                  'data-piece_count' => tutorial_contract.piece_count,
                  'data-term_teacher_id' => tutorial_contract.term_teacher_id || 0,
                  'class' => 'row align-items-center') do
        concat(
          content_tag(:div, class: 'col-9 pr-2') do
            concat select_tag_piece_count(tutorial_contract)
            concat select_tag_term_teacher_id(tutorial_contract, term_teachers)
          end,
        )
        concat(
          content_tag(:div, class: 'col-3 px-0 d-flex align-items-end') do
            button_tag('消', id: "button_delete_#{tutorial_contract.id}", class: %w[btn btn-sm btn-danger])
          end,
        )
      end
    end
  end

  def select_tag_is_contracted(group_contract)
    select = { '受講しない' => false, '受講する' => true }
    select_tag(
      :is_contracted,
      options_for_select(select, selected: group_contract.is_contracted),
      id: "select_is_contracted_#{group_contract.id}",
      class: 'form-control form-control-sm',
    )
  end

  def group_contract_table_cell(group_contracts, term_student, term_group)
    group_contract = group_contracts.find do |item|
      item.term_student_id == term_student.id && item.term_group_id == term_group.id
    end
    td_class = group_contract.is_contracted ? 'align-middle bg-warning-light min-width-150' : 'align-middle min-width-150'
    content_tag(:td, class: td_class) do
      content_tag(:div,
                  'data-id' => group_contract.id,
                  'data-is_contracted' => group_contract.is_contracted) do
        select_tag_is_contracted(group_contract)
      end
    end
  end
end
