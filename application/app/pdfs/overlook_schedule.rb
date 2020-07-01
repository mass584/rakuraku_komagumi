class OverlookSchedule < Prawn::Document
  include ApplicationHelper

  def initialize(term)
    super(
      page_size: 'A4', # 595.28 x 841.89
      page_layout: :landscape,
      left_margin: 20,
      right_margin: 20
    )
    font Rails.root.join('vendor', 'assets', 'fonts', 'ipaexm.ttf')
    text "#{term.name}予定表", align: :center, size: 16
    move_down 10
    schedule_table(term)
    move_down 5
    text "出力日時：#{Time.zone.now.strftime('%Y年%m月%d日, %H:%M:%S')}", align: :right, size: 9
  end

  private

  def schedule_table(term)
    max_width = 801
    header1_col_width = 40
    header2_col_width = 15
    body_col_width = (max_width - header1_col_width - header2_col_width) / term.max_period
    font_size(7) do
      table table_cells(term), cell_style: { width: body_col_width, padding: 2.5 } do
        cells.borders = [:top, :bottom, :right, :left]
        cells.border_width = 1.0
        columns(0).width = header1_col_width
        columns(1).width = header2_col_width
        rows(0..-1).each do |row|
          row.height = 20 if row.height < 20
        end
        rows(0).height = 13
        term.date_array.each_with_index do |_n, idx|
          border_row_number = (idx + 1) * (term.max_seat + 1)
          rows(border_row_number).height = 2
        end
        self.header = true
      end
    end
  end

  def table_cells(term)
    pieces = Piece.get_all_pieces(term)
    col_items = [header(term)]
    pieces.map do |date, date_item|
      table = term.seat_array.map do |seat|
        header1_cell = [{
          content: print_date(date, term.type),
          background_color: COLOR_HEADER,
          rowspan: term.max_seat,
        }]
        header2_cell = [{
          content: seat.to_s,
          background_color: COLOR_HEADER,
        }]
        body_cell = date_item.map do |_period, period_item|
          content = period_item.map do |piece|
            "#{piece.student.name_with_grade(term)} #{item.subject.name} (#{item.teacher.name})"
          end.join("\n")
          { content: content, background_color: COLOR_ENABLE }
        end
        header1_cell + header2_cell + body_cell
      end
      table + [{
        content: ' ',
        background_color: COLOR_BORDER,
        colspan: term.max_period + 2,
        height: 3,
      }]
    end
  end

  def header(term)
    begin_end_times = BeginEndTime.get_begin_end_times(term)
    header = [
      { content: ' ', background_color: COLOR_HEADER },
      { content: '席', background_color: COLOR_HEADER }
    ]
    body = term.period_array.map do |period|
      content =
        "#{period}限 #{begin_end_times[period].begin_at}〜#{begin_end_times[period].end_at}"
      { content: content, background_color: COLOR_HEADER }
    end
    header + body
  end
end
