class TeacherSchedule < Prawn::Document
  include ApplicationHelper
  include Common

  def initialize(term, teacher_ids)
    super(
      page_size: 'A4', # 595.28 x 841.89
      page_layout: rotate?(term) ? :landscape : :portrait,
      left_margin: 20,
      right_margin: 20
    )
    font Rails.root.join('vendor', 'assets', 'fonts', 'ipaexm.ttf')
    teacher_ids.each_with_index do |teacher_id, idx|
      teacher = Teacher.find(teacher_id)
      text "#{term.name}予定表 #{teacher.name}", align: :center, size: 16
      move_down 10
      schedule_table(teacher_id, term)
      move_down 5
      text "出力日時:#{Time.zone.now.strftime('%Y年%m月%d日, %H:%M:%S')}", align: :right, size: 9
      start_new_page if idx != teacher_ids.count - 1
    end
  end

  private

  def schedule_table(teacher_id, term)
    max_width = rotate?(term) ? 801 : 555
    header_col_width = 50
    body_col_width = (max_width - header_col_width) / term.max_period
    font_size(8) do
      table table_cells(teacher_id, term),
            cell_style: { width: body_col_width, padding: 3 } do
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

  def table_cells(teacher_id, term)
    pieces = Piece.get_pieces_for_teacher(teacher_id, term)
    rows = pieces.map do |date, date_item|
      cells = date_item.map do |period, period_item|
        content = period_item.map { |piece| print_piece_for_teacher(piece) }.join("\n")
        is_opened = term.teacher_requests.joins(:timetable).exists?(
          teacher_id: teacher_id,
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
