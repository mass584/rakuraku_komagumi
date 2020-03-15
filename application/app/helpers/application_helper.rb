module ApplicationHelper
  def youbi(number)
    %w[日 月 火 水 木 金 土][number]
  end

  def error_msg(messages)
    content_tag :ul do
      messages.each do |item|
        concat content_tag(:li, item)
      end
    end
  end

  def p_week(week_number)
    "第#{week_number}週"
  end

  def p_class(class_number)
    "#{class_number}限"
  end

  def p_date(day, type)
    case type
    when 'one_week' then
      youbi(day.wday).to_s
    when 'variable' then
      "#{day.strftime('%m/%d')} #{youbi(day.wday)}"
    end
  end

  def p_koma_from_teacher(schedule)
    "#{schedule.student.grade_when(schedule.schedulemaster)} #{schedule.student.fullname} [#{schedule.subject.name}]"
  end

  def p_koma_from_student(schedule)
    "[#{schedule.subject.name}] #{schedule.teacher.fullname}"
  end

  def week_before(id, week, target)
    case target
    when 'teacher' then
      params = { teacher_id: id, week: week - 1 }
      controller = 'teacherrequest'
    when 'student' then
      params = { student_id: id, week: week - 1 }
      controller = 'studentrequest'
    when 'schedule' then
      params = { week: week - 1 }
      controller = 'schedule'
    when 'timetable' then
      params = { week: week - 1 }
      controller = 'timetable'
    end
    if week > 1
      link_to '<<前週', controller: controller, action: 'index', params: params
    else
      '<<前週'
    end
  end

  def week_after(id, week, max_week, target)
    case target
    when 'teacher' then
      params = { teacher_id: id, week: week + 1 }
      controller = 'teacherrequest'
    when 'student' then
      params = { student_id: id, week: week + 1 }
      controller = 'studentrequest'
    when 'schedule' then
      params = { week: week + 1 }
      controller = 'schedule'
    when 'timetable' then
      params = { week: week + 1 }
      controller = 'timetable'
    end
    if week < max_week
      link_to '次週>>', controller: controller, action: 'index', params: params
    else
      '次週>>'
    end
  end
end
