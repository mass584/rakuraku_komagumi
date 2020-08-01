class TeacherSchedule < Prawn::Document
  include Common

  def initialize(term, teacher_term)
    super(
      page_size: 'A4', # 595.28 x 841.89
      page_layout: rotate?(term) ? :landscape : :portrait,
      left_margin: 20,
      right_margin: 20
    )
    font Rails.root.join('vendor', 'assets', 'fonts', 'ipaexm.ttf')
    text "#{term.name}予定表 #{teacher_term.teacher.name}", align: :center, size: 16
    move_down 10
    pdf_table(term, teacher_term)
    move_down 5
    text "#{Time.zone.now.strftime('%Y/%m/%d %H:%M')}", align: :right, size: 9
  end

  private

  def pdf_table(term, teacher_term)
    max_width = rotate?(term) ? 801 : 555
    header_col_width = 80
    body_col_width = (max_width - header_col_width) / term.max_period
    font_size(8) do
      table pdf_table_cells(term, teacher_term),
            cell_style: { width: body_col_width, padding: 3, leading: 2 } do
        cells.borders = [:top, :bottom, :right, :left]
        cells.border_width = 1.0
        columns(0).width = header_col_width
        rows(0..-1).each do |row|
          row.height = 25 if row.height < 25
        end
        self.header = true
      end
    end
  end

  def pdf_table_cells(term, teacher_term)
    term.date_array.reduce([header(term)]) do |a_date, date|
      a_date.concat(
        [
          term.period_array.reduce([header_left(date)]) do |a_period, period|
            content = term.pieces_for_teacher(teacher_term.id).dig(date, period).to_a.map do |piece|
              print_piece_for_teacher(piece)
            end.join("\n")
            is_opened = term.teacher_requests.joins(:timetable).exists?(
              teacher_term_id: teacher_term.id,
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
