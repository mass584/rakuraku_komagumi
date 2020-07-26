class StudentSchedule < Prawn::Document
  include ApplicationHelper
  include Common

  def initialize(term, student_ids)
    super(
      page_size: 'A4', # 595.28 x 841.89
      page_layout: rotate?(term) ? :landscape : :portrait,
      left_margin: 20,
      right_margin: 20
    )
    font Rails.root.join('vendor', 'assets', 'fonts', 'ipaexm.ttf')
    student_ids.each_with_index do |student_id, idx|
      student = Student.find(student_id)
      text "#{term.name}予定表 #{student.name_with_grade(term)}", align: :center, size: 16
      move_down 10
      schedule_table(student_id, term)
      move_down 5
      text "出力日時:#{Time.zone.now.strftime('%Y年%m月%d日, %H:%M:%S')}", align: :right, size: 9
      start_new_page if idx != student_ids.count - 1
    end
  end

  private

  def schedule_table(student_id, term)
    max_width = rotate?(term) ? 801 : 555
    header_col_width = 50
    body_col_width = (max_width - header_col_width) / term.max_period
    font_size(8) do
      table table_cells(student_id, term),
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

  def table_cells(student_id, term)
    pieces = Piece.get_pieces_for_student(student_id, term)
    rows = pieces.map do |date, date_item|
      cells = date_item.map do |period, period_item|
        content = period_item.map { |piece| print_piece_for_student(piece) }.join("\n")
        is_opened = term.student_requests.joins(:timetable).exists?(
          student_id: student_id,
          'timetables.date': date,
          'timetables.period': period,
        )
        background_color = is_opened ? COLOR_ENABLE : COLOR_DISABLE
        { content: content, background_color: background_color }
      end
      [{ content: print_date(date), background_color: COLOR_HEADER }] + cells
    end
    [header(term)] + rows
  end
end
