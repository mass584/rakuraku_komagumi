class TeacherSchedule < Prawn::Document
  include Common

  def initialize(term, term_teachers, tutorial_pieces, term_groups, timetables)
    page_layout = rotate?(term) ? :landscape : :portrait
    super(page_size: 'A4', page_layout: page_layout, left_margin: 20, right_margin: 20)
    font Rails.root.join('vendor', 'fonts', 'ipaexm.ttf')
    term_teachers.each_with_index do |term_teacher, index|
      text "#{term.name}予定表 #{term_teacher.teacher.name}"
      move_down 10
      pdf_table(term, term_teacher, tutorial_pieces, term_groups, timetables)
      start_new_page if index != term_teachers.count - 1
    end
    number_pages('<page> / <total>', { at: [bounds.right - 50, 0], size: 7 })
  end

  private

  def pdf_table(term, term_teacher, tutorial_pieces, term_groups, timetables)
    max_width = rotate?(term) ? 801 : 555
    header_col_width = 80
    body_col_width = (max_width - header_col_width) / term.period_count
    font_size(8) do
      table table_cells(term, term_teacher, tutorial_pieces, term_groups, timetables),
            cell_style: { width: body_col_width, padding: 3, leading: 2 } do
        cells.borders = [:top, :bottom, :right, :left]
        cells.border_width = 1.0
        columns(0).width = header_col_width
        row(0).text_color = 'ffffff'
        self.header = true
      end
    end
  end

  def table_cells(term, term_teacher, tutorial_pieces, term_groups, timetables)
    term.date_index_array.reduce([header(term)]) do |rows, date_index|
      rows + [
        term.period_index_array.reduce([header_left(term, date_index)]) do |cols, period_index|
          tutorial_pieces_array = tutorial_pieces.filter do |tutorial_piece|
            tutorial_piece[:date_index] == date_index &&
              tutorial_piece[:period_index] == period_index &&
              tutorial_piece[:term_teacher_id] == term_teacher.id
          end.to_a
          timetable = timetables.find do |item|
            item[:date_index] == date_index &&
              item[:period_index] == period_index &&
              item[:term_teacher_id] == term_teacher.id
          end
          is_enabled_term_group = term_groups.find do |item|
            item[:date_index] == date_index &&
              item[:period_index] == period_index &&
              item[:term_teacher_id] == term_teacher.id
          end
          cols + [table_cell(is_enabled_term_group, tutorial_pieces_array, timetable)]
        end
      ]
    end
  end

  def table_cell(is_enabled_term_group, tutorial_pieces, timetable)
    if timetable[:is_closed]
      {
        content: '休講',
        background_color: COLOR_DISABLE,
        height: 25,
      }
    elsif timetable[:group_name]
      {
        content: timetable[:group_name],
        background_color: is_enabled_term_group ? COLOR_ENABLE : COLOR_DISABLE,
        height: 25,
      }
    elsif !timetable[:is_vacant]
      {
        content: '出勤不可',
        background_color: COLOR_DISABLE,
        height: 25,
      }
    elsif tutorial_pieces.present?
      {
        content: tutorial_pieces.map do |tutorial_piece|
          "#{tutorial_piece.student_name}（#{tutorial_piece.tutorial_name}）"
        end.join("\n"),
        background_color: COLOR_ENABLE,
        height: 25,
      }
    else
      {
        content: ' ',
        background_color: COLOR_PLAIN,
        height: 25,
      }
    end
  end
end
