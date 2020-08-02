class OverlookSchedule < Prawn::Document
  include Common

  def initialize(term, seats)
    super(
      page_size: 'A4', # 595.28 x 841.89
      page_layout: :landscape,
      left_margin: 20,
      right_margin: 20
    )
    font Rails.root.join('vendor', 'assets', 'fonts', 'ipaexm.ttf')
    text "#{term.name}予定表", align: :center, size: 16
    move_down 10
    pdf_table(term, seats)
    move_down 5
    text Time.zone.now.strftime('%Y/%m/%d %H:%M').to_s, align: :right, size: 9
  end

  private

  def pdf_table(term, seats)
    max_width = 801
    header1_col_width = 80
    header2_col_width = 20
    body_col_width = (max_width - header1_col_width - header2_col_width) / (term.max_period * 3)
    font_size(7) do
      table table_cells(term, seats),
            cell_style: { width: body_col_width, padding: 3, leading: 2 } do
        cells.borders = [:top, :bottom, :right, :left]
        cells.border_width = 1.0
        columns(0).width = header1_col_width
        columns(1).width = header2_col_width
        term.period_array.each do |period|
          columns(1 + period * 2).width = body_col_width * 2
        end
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

  def table_cells(term, seats)
    term.date_array.reduce([]) do |a_date, date|
      a_date.concat(
        term.seat_array.reduce([header_top(term)]) do |a_seat, seat|
          a_seat.concat(
            [
              term.period_array.reduce(
                header_left(term, date, seat),
              ) do |a_period, period|
                a_period.concat(
                  [
                    {
                      background_color: COLOR_ENABLE,
                      content: seats[date][period][seat]&.teacher_term&.teacher&.name,
                    },
                    {
                      background_color: COLOR_ENABLE,
                      content:
                      term.all_pieces.dig(date, period).to_a.map do |piece|
                        print_piece_for_teacher(piece)
                      end.join("\n"),
                    }
                  ],
                )
              end
            ],
          )
        end,
      )
    end
  end

  def header_top(term)
    begin_end_times = BeginEndTime.get_begin_end_times(term)
    term.period_array.reduce(
      [
        { content: ' ', background_color: COLOR_HEADER },
        { content: '席', background_color: COLOR_HEADER }
      ],
    ) do |a_period, period|
      a_period.concat([{
        background_color: COLOR_HEADER,
        content:
          "#{period}限
          #{begin_end_times[period].begin_at}〜
          #{begin_end_times[period].end_at}",
        colspan: 2,
      }])
    end
  end

  def header_left(term, date, seat)
    if seat == 1
      [
        {
          background_color: COLOR_HEADER,
          content: print_date(date),
          rowspan: term.max_seat,
        },
        {
          background_color: COLOR_HEADER,
          content: print_seat(seat),
        }
      ]
    else
      [
        {
          background_color: COLOR_HEADER,
          content: print_seat(seat),
        }
      ]
    end
  end
end
