class PdfTeacherSchedule < Prawn::Document
  include ApplicationHelper
  include PdfCommon

  def initialize(sc_id, teacher_ids)
    schedulemaster = Schedulemaster.find(sc_id)
    super(
      page_size: 'A4', # 595.28 x 841.89
      page_layout: rotate?(schedulemaster) ? :landscape : :portrait,
      left_margin: 20,
      right_margin: 20
    )
    font Rails.root.join('vendor', 'assets', 'fonts', 'ipaexm.ttf')
    teacher_ids.each_with_index do |teacher_id, idx|
      teacher = Teacher.find(teacher_id)
      text "#{schedulemaster.schedule_name}予定表 #{teacher.fullname}先生", align: :center, size: 16
      move_down 10
      schedule_table(teacher_id, schedulemaster)
      move_down 5
      text "出力日時:#{Time.now.strftime('%Y年%m月%d日, %H:%M:%S')}", align: :right, size: 9
      text "#{schedulemaster.room.roomname}教室 TEL:#{schedulemaster.room.tel}", align: :right, size: 9
      start_new_page if idx != teacher_ids.count - 1
    end
  end

  private

  def get_group_schedule(teacher_id, schedulemaster)
    group_schedule = []
    schedulemaster.group_subjects.each do |su|
      group_schedule[su.id] = schedulemaster.subject_schedulemaster_mappings.exists?(subject_id: su.id, teacher_id: teacher_id)
    end
    group_schedule
  end

  def schedule_table(teacher_id, schedulemaster)
    max_width = rotate?(schedulemaster) ? 801 : 555
    first_col_width = 50
    other_col_width = (max_width - first_col_width) / schedulemaster.totalclassnumber
    font_size(8) do
      table line_item_rows(teacher_id, schedulemaster), cell_style: { width: other_col_width, padding: 3 } do
        cells.borders = [:top, :bottom, :right, :left]
        cells.border_width = 1.0
        columns(0).width = first_col_width
        rows(0..-1).each do |row|
          row.height = 25 if row.height < 25
        end
        self.header = true
      end
    end
  end

  def line_item_rows(teacher_id, schedulemaster)
    timetables = Timetable.get_timetables(schedulemaster)
    individual_schedule = Schedule.get_teacher_schedules(teacher_id, schedulemaster)
    group_schedule = get_group_schedule(teacher_id, schedulemaster)
    koma_status = cell_koma_status(group_schedule, schedulemaster)

    col_items = [get_header(schedulemaster)]
    col_items.concat(individual_schedule.map do |key1, item1|
      col_item = [{ content: p_date(key1, schedulemaster.schedule_type), background_color: COLOR_HEADER }]
      col_item.concat(item1.map do |key2, item2|
        content = item2.count.zero? ?
          koma_status[timetables[key1][key2].status]['name'] :
          item2.map { |item3| p_koma_from_teacher(item3) }.join("\n")
        if schedulemaster.teacherrequests.joins(:timetable).exists?(
          teacher_id: teacher_id,
          'timetables.scheduledate': key1,
          'timetables.classnumber': key2,
        )
          color = koma_status[timetables[key1][key2].status]['color']
        else
          color = '7f7f7f'
        end
        { content: content, background_color: color }
      end)
      col_item
    end)
    col_items
  end
end
