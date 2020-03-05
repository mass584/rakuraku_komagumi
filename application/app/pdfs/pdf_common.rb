module PdfCommon
  COLOR_HEADER  = 'fdf5e6'.freeze
  COLOR_DISABLE = '7f7f7f'.freeze
  COLOR_ENABLE  = 'ffffff'.freeze
  COLOR_BORDER  = 'ffffff'.freeze

  def rotate?(schedulemaster)
    schedulemaster.totalclassnumber > 6 || schedulemaster.schedule_type == '通常時期'
  end

  def get_header(schedulemaster)
    timetablemaster = Timetablemaster.get_timetablemasters(schedulemaster)
    header = [
      { content: '日付', background_color: COLOR_HEADER }
    ]
    header.concat(schedulemaster.class_array.map do |item|
      header_str =
        "#{item}限\n#{timetablemaster[item].begintime.strftime('%H:%M')}〜#{timetablemaster[item].endtime.strftime('%H:%M')}"
      { content: header_str, background_color: COLOR_HEADER }
    end)
    header
  end

  def cell_koma_status(group_schedule, schedulemaster)
    koma_status = {}
    koma_status[-1] = { 'name' => '休講', 'color' => COLOR_DISABLE }
    koma_status[0] = { 'name' => '', 'color' => COLOR_ENABLE }
    schedulemaster.group_subjects.each do |su|
      color = group_schedule[su.id] ? COLOR_ENABLE : COLOR_DISABLE
      name = group_schedule[su.id] ? su.name : '集団授業(自習不可)'
      koma_status[su.id] = { 'name' => name, 'color' => color }
    end
    koma_status
  end
end
