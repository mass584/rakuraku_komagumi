class PdfOverlookSchedule < Prawn::Document
  include ApplicationHelper
  include PdfCommon

  def initialize(id)
    schedulemaster = Schedulemaster.find(id)
    super(
      page_size: 'A4', # 595.28 x 841.89
      page_layout: :landscape,
      left_margin: 20,
      right_margin: 20
    )
    font Rails.root.join('vendor', 'assets', 'fonts', 'ipaexm.ttf')
    text "#{schedulemaster.room.roomname}教室 #{schedulemaster.schedule_name}予定表", align: :center, size: 16
    text "出力日時：#{Time.now.strftime('%Y年%m月%d日, %H:%M:%S')}", align: :right, size: 7
    move_down 5
    schedule_table(schedulemaster)
  end

  private

  def schedule_table(schedulemaster)
    max_width = 801
    first_col_width = 40
    second_col_width = 15
    other_col_width = (max_width - first_col_width - second_col_width) / schedulemaster.totalclassnumber
    font_size(7) do
      table col_items(schedulemaster), cell_style: { width: other_col_width, padding: 2.5 } do
        cells.borders = [:top, :bottom, :right, :left]
        cells.border_width = 1.0
        columns(0).width = first_col_width
        columns(1).width = second_col_width
        rows(0..-1).each do |row|
          row.height = 20 if row.height < 20
        end
        rows(0).height = 13
        schedulemaster.date_count.times do |n|
          border_row_number = (n + 1) * (schedulemaster.seatnumber + 1)
          rows(border_row_number).height = 2
        end
        self.header = true
      end
    end
  end

  def col_items(schedulemaster)
    timetables = Timetable.get_timetables(schedulemaster)
    cell_koma_status = cell_koma_status(schedulemaster)
    individual_lesson = Schedule.get_all_schedules(schedulemaster)

    col_items = [get_header(schedulemaster)]
    schedulemaster.date_array.each do |date|
      (1..schedulemaster.seatnumber).each do |seat|
        col_item = if seat == 1
                     [{
                       content: p_date(date, schedulemaster.schedule_type),
                       background_color: COLOR_HEADER,
                       rowspan: schedulemaster.seatnumber,
                     }]
                   else
                     []
                   end
        col_item.push(content: seat.to_s, background_color: COLOR_HEADER)
        schedulemaster.class_array.each do |lesson|
          if individual_lesson[date][lesson].present?
            text = individual_lesson[date][lesson][0].map do |item|
              "#{item.student.fullname_with_grade(schedulemaster)} #{item.subject.name} (#{item.teacher.fullname})"
            end.join("\n")
            cell = { content: text, background_color: COLOR_ENABLE }
            individual_lesson[date][lesson].shift
          elsif (status = timetables[date][lesson].status) != 0
            cell = cell_koma_status[status]
          end
          col_item.push(cell)
        end
        col_items.push(col_item)
      end
      col_space = [{ content: ' ', background_color: COLOR_BORDER, colspan: schedulemaster.totalclassnumber + 2, height: 3 }]
      col_items.push(col_space)
    end
    col_items
  end

  def get_header(schedulemaster)
    timetablemaster = Timetablemaster.get_timetablemasters(schedulemaster)
    header = [
      { content: ' ', background_color: COLOR_HEADER },
      { content: '席', background_color: COLOR_HEADER }
    ]
    header.concat(schedulemaster.class_array.map do |item|
      header_str =
        "#{item}限 #{timetablemaster[item].begintime.strftime('%H:%M')}〜#{timetablemaster[item].endtime.strftime('%H:%M')}"
      { content: header_str, background_color: COLOR_HEADER }
    end)
    header
  end

  def cell_koma_status(schedulemaster)
    koma_status = {}
    koma_status[-1] = { content: '休講', background_color: COLOR_DISABLE }
    koma_status[0] = { content: '', background_color: COLOR_ENABLE }
    schedulemaster.group_subjects.each do |su|
      koma_status[su.id] = { content: su.name, background_color: COLOR_ENABLE }
    end
    koma_status
  end
end
