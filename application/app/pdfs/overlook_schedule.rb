class OverlookSchedule < Prawn::Document
  include Common

  def initialize(term, tutorial_pieces, seats, begin_end_times)
    super(page_size: 'A4', page_layout: :landscape, left_margin: 20, right_margin: 20, top_margin: 60)
    font Rails.root.join('vendor', 'fonts', 'ipaexm.ttf')
    pdf_table(term, tutorial_pieces, seats, begin_end_times)
    number_pages('<page> / <total>', { at: [bounds.right - 50, 0], size: 7 })
    number_pages("#{term.room.name} #{term.year}年度 #{term.name}予定表", at: [bounds.left, bounds.top + 20])
  end

  private

  def pdf_table(term, tutorial_pieces, seats, begin_end_times)
    max_width = 801
    header1_col_width = 80
    header2_col_width = 20
    body_col_width = (max_width - header1_col_width - header2_col_width) / (term.period_count * 3)
    font_size(7) do
      table table_cells(term, tutorial_pieces, seats, begin_end_times),
            cell_style: { width: body_col_width, padding: 2, leading: 2 } do
        cells.border_width = 0.5
        cells.border_color = COLOR_BORDER
        columns(0).width = header1_col_width
        columns(1).width = header2_col_width
        row(0).text_color = 'ffffff'
        term.period_index_array.each do |period_index|
          columns(1 + period_index * 2).width = body_col_width * 2
        end
        self.header = true
      end
    end
  end

  def table_cells(term, tutorial_pieces, seats, begin_end_times)
    [header_rows(term, begin_end_times)] + term.date_index_array.product(term.seat_index_array).map do |date_index, seat_index|
      header_cols(term, date_index, seat_index) + term.period_index_array.map do |period_index|
        seat = seats.to_a.find do |item|
          item[:date_index] == date_index &&
            item[:period_index] == period_index &&
            item[:seat_index] == seat_index
        end
        tutorial_pieces_array = tutorial_pieces.to_a.filter do |item|
          item[:date_index] == date_index &&
            item[:period_index] == period_index &&
            item[:seat_index] == seat_index
        end
        table_cell(seat, tutorial_pieces_array)
      end.flatten
    end
  end

  def header_rows(term, begin_end_times)
    term.period_index_array.reduce(
      [
        { content: ' ', background_color: COLOR_HEADER, height: 22 },
        { content: '席', background_color: COLOR_HEADER, height: 22 }
      ],
    ) do |cols, period_index|
      begin_end_time = begin_end_times.find { |item| item[:period_index] == period_index }
      begin_at = I18n.l begin_end_time.begin_at
      end_at = I18n.l begin_end_time.end_at
      cols.concat([{
        background_color: COLOR_HEADER,
        content: "#{period_index}限（#{begin_at}〜#{end_at}）",
        colspan: 2,
        height: 22,
      }])
    end
  end

  def header_cols(term, date_index, seat_index)
    if seat_index == 1
      [
        {
          content: term.display_date(date_index),
          rowspan: term.seat_count,
        },
        {
          content: "席#{seat_index}",
        }
      ]
    else
      [
        {
          content: "席#{seat_index}",
        }
      ]
    end
  end

  def table_cell(seat, tutorial_pieces)
    if seat[:group_name].present?
      [
        {
          background_color: COLOR_ENABLE,
          content: seat[:group_name],
          colspan: 2,
          height: 22,
        }
      ]
    elsif seat[:is_closed]
      [
        {
          background_color: COLOR_DISABLE,
          content: '休講',
          colspan: 2,
          height: 22,
        }
      ]
    else
      [
        {
          background_color: seat[:teacher_name].present? ? COLOR_ENABLE : COLOR_PLAIN,
          content: seat[:teacher_name],
          borders: [:top, :bottom, :left],
          height: 22,
        },
        {
          background_color: tutorial_pieces.present? ? COLOR_ENABLE : COLOR_PLAIN,
          content: tutorial_pieces.map do |tutorial_piece|
            "#{tutorial_piece[:student_name]}（#{tutorial_piece[:tutorial_name]}）"
          end.join("\n"),
          borders: [:top, :bottom, :right],
          height: 22,
        }
      ]
    end
  end
end
