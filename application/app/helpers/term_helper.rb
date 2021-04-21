module TermHelper
  def terms_table_content(terms)
    {
      attributes: %w[スケジュール名 種別 年度 開始日 終了日 編集 選択],
      records: terms.map do |term|
        term_table_record(term)
      end,
    }
  end

  def term_table_record(term)
    {
      id: term.id,
      tds: [
        term.name,
        term.term_type_i18n,
        "#{term.year}年度",
        "#{l term.begin_at}",
        "#{l term.end_at}",
        content_tag(:div) do
          render partial: 'terms/edit', locals: { term: term }
        end,
        content_tag(:div) do
          link_to '選択', term_path(term, {term_id: term.id}), { class: 'btn btn-dark' }
        end,
      ],
    }
  end

  def term_schedule_table_cell(tutorial_pieces, seats, date_index, period_index, seat_index)
    seat = seats.find do |item|
      item.date_index == date_index && item.period_index == period_index && item.seat_index == seat_index
    end
    filtered_tutorial_pieces = tutorial_pieces.filter do |item|
      item.date_index == date_index && item.period_index == period_index && item.seat_index == seat_index
    end
    content_tag(:td, class: term_schedule_table_cell_class(seat, filtered_tutorial_pieces)) do
      content_tag(:div, class: 'min-height-60 d-flex flex-column justify-content-center') do
        term_schedule_table_cell_inner(seat, filtered_tutorial_pieces)
      end
    end
  end

  def term_schedule_table_cell_class(seat, tutorial_pieces)
    if seat.is_closed
      'align-middle bg-secondary'
    elsif seat.term_group_id.present?
      'align-middle bg-warning-light'
    elsif tutorial_pieces.present?
      'align-middle bg-warning-light'
    else
      'align-middle'
    end
  end

  def term_schedule_table_cell_inner(seat, tutorial_pieces)
    if seat.is_closed
      '休講'
    elsif seat.group_name.present?
      seat.group_name
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
