module ScheduleHelper
  def get_date_td(schedulemaster, timetable)
    if timetable.classnumber == 1
      content_tag(:td, p_date(timetable.scheduledate, schedulemaster.schedule_type), class: ['date', 'koma-top-head'])
    elsif timetable.classnumber == schedulemaster.totalclassnumber
      content_tag(:td, ' ', class: ['date', 'koma-bottom-head'])
    else
      content_tag(:td, ' ', class: ['date', 'koma-center-head'])
    end
  end

  def get_class_td(schedulemaster, timetable)
    if timetable.classnumber == 1
      content_tag(:td, p_class(timetable.classnumber), class: ['class', 'koma-top-head'])
    elsif timetable.classnumber == schedulemaster.totalclassnumber
      content_tag(:td, p_class(timetable.classnumber), class: ['class', 'koma-bottom-head'])
    else
      content_tag(:td, p_class(timetable.classnumber), class: ['class', 'koma-center-head'])
    end
  end

  def get_seat_td(schedulemaster, timetable)
    if timetable.classnumber == 1
      content_tag(:td, '',
                  'class' => ['seat', 'koma-top-head'],
                  'id' => "seat_#{timetable.id}",
                  'data-id' => timetable.id)
    elsif timetable.classnumber == schedulemaster.totalclassnumber
      content_tag(:td, '',
                  'class' => ['seat', 'koma-bottom-head'],
                  'id' => "seat_#{timetable.id}",
                  'data-id' => timetable.id)
    else
      content_tag(:td, '',
                  'class' => ['seat', 'koma-center-head'],
                  'id' => "seat_#{timetable.id}",
                  'data-id' => timetable.id)
    end
  end

  def get_koma_td(schedulemaster, timetable, teacher, waku_id)
    teacher_request_is_ready =
      schedulemaster.teacherrequestmasters.exists?(teacher_id: teacher.id, status: 1)
    teacher_request_is_true =
      schedulemaster.teacherrequests.joins(:timetable).exists?(
        teacher_id: teacher.id,
        'timetables.classnumber': timetable.classnumber,
        'timetables.scheduledate': timetable.scheduledate,
      )
    available_student_list =
      schedulemaster.studentrequests.where(timetable_id: timetable.id).pluck(:student_id)
    case timetable.status
    when 0 then
      if !teacher_request_is_ready
        content = 'スケジュール未定'
        td_class = ['koma', 'koma-disable']
      elsif !teacher_request_is_true
        content = '出勤不可'
        td_class = ['koma', 'koma-disable']
      else
        content = get_dropbox(timetable.id, teacher.id, waku_id, available_student_list)
        td_class = ['koma']
      end
    when -1 then
      content = '休講'
      td_class = ['koma', 'koma-disable']
    else
      subject_id = timetable.status
      content = schedulemaster.subjects.find(subject_id).name
      td_class = if schedulemaster.subject_schedulemaster_mappings.exists?(teacher_id: teacher.id, subject_id: subject_id)
                   ['koma', 'koma-group-enable']
                 else
                   ['koma', 'koma-group-disable']
                 end
    end
    if waku_id.zero?
      td_class.push('koma-left')
    end
    if waku_id == 1
      td_class.push('koma-right')
    end
    if timetable.classnumber == 1
      td_class.push('koma-top')
    elsif timetable.classnumber == schedulemaster.totalclassnumber
      td_class.push('koma-bottom')
    else
      td_class.push('koma-center')
    end
    content_tag(:td, content, class: td_class)
  end

  def get_dropbox(timetable_id, teacher_id, waku_id, student_list)
    div_class    = ['dropbox', 'ui-widget-header']
    div_id       = "dropbox_koma_#{timetable_id}_#{teacher_id}_#{waku_id}"
    content_tag(:div, '',
                :class => div_class,
                :id => div_id,
                'data-teacher_id' => teacher_id,
                'data-timetable_id' => timetable_id,
                'data-studentrequest' => student_list.to_s,
                'data-sid' => waku_id)
  end
end
