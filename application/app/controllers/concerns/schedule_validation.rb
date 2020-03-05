module ScheduleValidation
  def get_individual_schedule_for_student(schedulemaster, date, class_array, student_id)
    individual_schedule = {}
    class_array.each do |n|
      individual_schedule[n] = schedulemaster.schedules.joins(:timetable).exists?(
        student_id: student_id,
        'timetables.scheduledate': date,
        'timetables.classnumber': n,
      )
    end
    individual_schedule
  end

  def get_individual_schedule_for_teacher(schedulemaster, date, class_array, teacher_id)
    individual_schedule = {}
    class_array.each do |n|
      individual_schedule[n] = schedulemaster.schedules.joins(:timetable).exists?(
        teacher_id: teacher_id,
        'timetables.scheduledate': date,
        'timetables.classnumber': n,
      )
    end
    individual_schedule
  end

  def get_group_schedule_for_student(schedulemaster, date, class_array)
    group_schedule = {}
    class_array.each do |n|
      timetable_status = schedulemaster.timetables.find_by(
        'timetables.scheduledate': date,
        'timetables.classnumber': n,
      ).status
      group_schedule[n] = schedulemaster.classnumbers.exists?(
        student_id: student_id,
        subject_id: timetable_status,
        number: 1,
      )
    end
    group_schedule
  end

  def get_group_schedule_for_teacher(schedulemaster, date, class_array)
    group_schedule = {}
    class_array.each do |n|
      timetable_status = schedulemaster.timetables.find_by(
        'timetables.scheduledate': date,
        'timetables.classnumber': n,
      ).status
      group_schedule[n] = schedulemaster.classnumbers.exists?(
        teacher_id: teacher_id,
        subject_id: timetable_status,
        number: 1,
      )
    end
    group_schedule
  end

  def blank_class_check(group_schedule, individual_schedule, class_array, blank_count_max)
    ret = true
    blank_count = 0
    blank_count_tmp = 0
    class_begin = false
    class_array.each do |n|
      if group_schedule[n] || individual_schedule[n]
        blank_count += blank_count_tmp if class_begin
        blank_count_tmp = 0
        class_begin = true
      else
        blank_count_tmp += 1
      end
      ret = false if blank_count > blank_count_max
    end
    ret
  end
end
