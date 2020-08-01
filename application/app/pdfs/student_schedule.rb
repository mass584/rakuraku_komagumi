class StudentSchedule < Prawn::Document
  include Common

  def initialize(term, student_term)
    super(
      page_size: 'A4', # 595.28 x 841.89
      page_layout: rotate?(term) ? :landscape : :portrait,
      left_margin: 20,
      right_margin: 20
    )
    font Rails.root.join('vendor', 'assets', 'fonts', 'ipaexm.ttf')
    text "#{term.name}予定表 #{student_term.student.name}", align: :center, size: 16
    move_down 10
    pdf_table(term, student_term)
    move_down 5
    text "出力日時:#{Time.zone.now.strftime('%Y年%m月%d日')}", align: :right, size: 9
  end

  private

  def pdf_table(term, student_term)
    max_width = rotate?(term) ? 801 : 555
    header_col_width = 50
    body_col_width = (max_width - header_col_width) / term.max_period
    font_size(8) do
      table table_cells(term, student_term),
            cell_style: { width: body_col_width, padding: 3 } do
        cells.borders = [:top, :bottom, :right, :left]
        cells.border_width = 1.0
        columns(0).width = header_col_width
        rows(0..-1).each do |row|
          row.height = 20 if row.height < 20
        end
        self.header = true
      end
    end
  end

  def table_cells(term, student_term)
    term.date_array.reduce([header(term)]) do |a_date, date|
      a_date.concat(
        [
          term.period_array.reduce([header_left(date)]) do |a_period, period|
            content = term.pieces_for_student(student_term.id).dig(date, period).to_a.map do |piece|
              print_piece_for_student(piece)
            end.join("\n")
            is_opened = term.student_requests.joins(:timetable).exists?(
              student_term_id: student_term.id,
              'timetables.date': date,
              'timetables.period': period,
            )
            background_color = is_opened ? COLOR_ENABLE : COLOR_DISABLE
            a_period.concat([{
              content: content,
              background_color: background_color,
            }])
          end
        ],
      )
    end
  end
end
