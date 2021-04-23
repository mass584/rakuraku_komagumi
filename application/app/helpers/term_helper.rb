module TermHelper
  def terms_table_content(terms)
    {
      attributes: %w[年度 スケジュール名 期間種別 開始日 終了日 時限数 座席数 座席あたりの生徒数 編集 開く],
      records: terms.map do |term|
        term_table_record(term)
      end,
    }
  end

  def term_table_record(term)
    {
      id: term.id,
      tds: [
        "#{term.year}年度",
        term.name,
        term.term_type_i18n,
        (l term.begin_at).to_s,
        (l term.end_at).to_s,
        "#{term.period_count}時限",
        "#{term.seat_count}席",
        "1対#{term.position_count}",
        content_tag(:div) do
          render partial: 'terms/edit', locals: { term: term }
        end,
        content_tag(:div) do
          link_to '開く', term_path(term, { term_id: term.id })
        end
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
