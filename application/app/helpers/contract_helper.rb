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

  def tutorial_contract_table_cell(tutorial_contract, term_teachers)
    td_class = tutorial_contract.is_active? ? 'align-middle mw-200 bg-active' : 'align-middle mw-200'
    content_tag(:td, class: td_class) do
      concat(
        content_tag(:div,
                    'data-id' => tutorial_contract.id,
                    'data-piece_count' => tutorial_contract.piece_count,
                    'data-term_teacher_id' => tutorial_contract.term_teacher_id,
                    'class' => 'row align-items-center') do
          concat(
            content_tag(:div, class: 'col-9 pl-4 pr-2') do
              concat select_tag_piece_count(tutorial_contract)
              concat select_tag_term_teacher_id(tutorial_contract, term_teachers)
            end,
          )
          concat(
            content_tag(:div, class: 'col-3 pl-0 pr-4 d-flex align-items-end') do
              concat button_tag(
                '消',
                id: "button_delete_#{tutorial_contract.id}",
                class: %w[btn btn-sm btn-danger],
              )
            end,
          )
        end,
      )
    end
  end
end
