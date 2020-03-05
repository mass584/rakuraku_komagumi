module TimetableHelper
  def time_field_timetable(timetablemaster, prop)
    time_field prop, timetablemaster.classnumber,
               id: prop,
               value: timetablemaster[prop].strftime('%H:%M')
  end

  def select_tag_timetable_status(schedulemaster, timetable)
    select = [['通常授業', 0], ['休講', -1]]
    schedulemaster.group_subjects.each do |s|
      select.push([s.name, s.id])
    end
    select_tag :status, options_for_select(select, timetable.status),
               id: 'select_status'
  end

  def timetable_status(schedulemaster, timetable)
    content_tag(:div, select_tag_timetable_status(schedulemaster, timetable),
                'data-id': timetable.id,
                'data-status': timetable.status)
  end

  def get_select_class(status)
    case status
    when 0 then
      'selectbox-normal'
    when -1 then
      'selectbox-blank'
    else
      'selectbox-group'
    end
  end
end
