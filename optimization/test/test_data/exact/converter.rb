schedulemaster_record = Schedulemaster.where(id: 47)
schedulemaster = schedulemaster_record.first
term_type = lambda do |str|
  return 0 if str == '通常時期'
  return 1 if str == '講習時期'
  return 2 if str == 'テスト対策'
end
term = {
  id: 47,
  name: schedulemaster.schedule_name,
  year: 2019,
  term_type: term_type.call(schedulemaster.schedule_type),
  begin_at: schedulemaster.begindate,
  end_at: schedulemaster.enddate,
  period_count: schedulemaster.totalclassnumber,
  seat_count: schedulemaster.seatnumber,
  position_count: 2
}
timetables = schedulemaster_record.joins(:timetables).select(
  'timetables.id',
  :scheduledate,
  :classnumber,
  :status
).map do |item|
  date_index = (item.scheduledate - schedulemaster.begindate).to_i + 1
  {
    id: item.id,
    date_index: date_index,
    period_index: item.classnumber,
    term_group_id: item.status.positive? ? item.status : nil,
    is_closed: item.status == -1
  }
end
teacher_optimization_rule_record = schedulemaster.calculation_rules.find_by(
  eval_target: 'teacher'
)
teacher_optimization_rule = {
  single_cost: teacher_optimization_rule_record.single_cost,
  different_pair_cost: teacher_optimization_rule_record.different_pair_cost,
  occupation_limit: teacher_optimization_rule_record.total_class_max,
  occupation_costs: teacher_optimization_rule_record.total_class_cost.split(',').map(&:to_i),
  blank_limit: teacher_optimization_rule_record.blank_class_max,
  blank_costs: teacher_optimization_rule_record.blank_class_cost.split(',').map(&:to_i),
}
student_optimization_rule_record = schedulemaster.calculation_rules.find_by(
  eval_target: 'student'
)
student_optimization_rule_j3_record = schedulemaster.calculation_rules.find_by(
  eval_target: 'student3g'
)
student_optimization_rules = [11, 12, 13, 14, 15, 16, 21, 22, 23, 31, 32, 33, 99].map do |school_grade|
  record = school_grade == 23 ? student_optimization_rule_j3_record : student_optimization_rule_record
  {
    school_grade: school_grade,
    occupation_limit: record.total_class_max,
    occupation_costs: record.total_class_cost.split(',').map(&:to_i),
    blank_limit: record.blank_class_max,
    blank_costs: record.blank_class_cost.split(',').map(&:to_i),
    interval_cutoff: record.interval_cost.split(',').count - 1,
    interval_costs: record.interval_cost.split(',').map(&:to_i)
  }
end
term_teachers = schedulemaster_record.joins(
  teacher_schedulemaster_mappings: [teacher: :teacherrequestmasters]
).where(
  'teacherrequestmasters.schedulemaster_id': 47
).select(
  'teachers.id', 'teacherrequestmasters.status'
).map do |item|
  {
    id: item.id,
    name: "講師#{item.id}",
    vacancy_status: item.status.zero? ? 0 : 2,
  }
end
term_students = schedulemaster_record.joins(
  student_schedulemaster_mappings: [student: :studentrequestmasters]
).where(
  'studentrequestmasters.schedulemaster_id': 47
).select(
  'students.id', 'studentrequestmasters.status'
).map do |item|
  {
    id: item.id,
    name: "生徒#{item.id}",
    vacancy_status: item.status.zero? ? 0 : 2,
  }
end
term_tutorials = schedulemaster_record.joins(
  subject_schedulemaster_mappings: :subject
).select(
  'subjects.id', 'subjects.name', 'subjects.classtype'
).select do |item|
  item.classtype == '個別授業'
end.map do |item|
  {
    id: item.id,
    name: item.name
  }
end
term_groups = schedulemaster_record.joins(
  subject_schedulemaster_mappings: :subject
).select(
  'subjects.id', 'subjects.name', 'subjects.classtype'
).select do |item|
  item.classtype == '集団授業'
end.map do |item|
  {
    id: item.id,
    name: item.name
  }
end
student_vacancies = term_students.product(timetables).map do |term_student, timetable|
  scheduledate = schedulemaster.begindate + (timetable[:date_index] - 1).days
  {
    date_index: timetable[:date_index],
    period_index: timetable[:period_index],
    term_student_id: term_student[:id],
    is_vacant: schedulemaster_record.joins(
      studentrequests: :timetable
    ).exists?(
      'timetables.scheduledate': scheduledate,
      'timetables.classnumber': timetable[:period_index],
      'studentrequests.student_id': term_student[:id]
    )
  }
end
teacher_vacancies = term_teachers.product(timetables).map do |term_teacher, timetable|
  scheduledate = schedulemaster.begindate + (timetable[:date_index] - 1).days
  {
    date_index: timetable[:date_index],
    period_index: timetable[:period_index],
    term_teacher_id: term_teacher[:id],
    is_vacant: schedulemaster_record.joins(
      teacherrequests: :timetable
    ).exists?(
      'timetables.scheduledate': scheduledate,
      'timetables.classnumber': timetable[:period_index],
      'teacherrequests.teacher_id': term_teacher[:id]
    )
  }
end
tutorial_contracts = schedulemaster_record.joins(
  classnumbers: :subject
).where('subjects.classtype': '個別授業').select(
  'classnumbers.number',
  'classnumbers.student_id',
  'classnumbers.teacher_id',
  'classnumbers.subject_id'
).map do |classnumber|
  {
    term_student_id: classnumber.student_id,
    term_tutorial_id: classnumber.subject_id,
    term_teacher_id: classnumber.teacher_id,
    piece_count: classnumber.number
  }
end
teacher_group_timetables = schedulemaster_record.joins(
  'JOIN timetables on timetables.schedulemaster_id = schedulemasters.id JOIN subject_schedulemaster_mappings on timetables.status = subject_schedulemaster_mappings.subject_id and schedulemasters.id = subject_schedulemaster_mappings.schedulemaster_id'
).where('timetables.status': 1..Float::INFINITY).select('timetables.*', 'subject_schedulemaster_mappings.teacher_id').map do |timetable|
  date_index = (timetable.scheduledate - schedulemaster.begindate).to_i + 1
  {
    date_index: date_index,
    period_index: timetable.classnumber,
    term_group_id: timetable.status,
    term_teacher_id: timetable.teacher_id
  }
end
student_group_timetables = schedulemaster_record.joins(
  'JOIN timetables on timetables.schedulemaster_id = schedulemasters.id JOIN subject_schedulemaster_mappings on timetables.status = subject_schedulemaster_mappings.subject_id and schedulemasters.id = subject_schedulemaster_mappings.schedulemaster_id JOIN classnumbers on classnumbers.subject_id = subject_schedulemaster_mappings.subject_id and classnumbers.schedulemaster_id = schedulemasters.id'
).where('timetables.status': 1..Float::INFINITY, 'classnumbers.number': 1..Float::INFINITY).select('timetables.*', 'classnumbers.student_id').map do |timetable|
  date_index = (timetable.scheduledate - schedulemaster.begindate).to_i + 1
  {
    date_index: date_index,
    period_index: timetable.classnumber,
    term_group_id: timetable.status,
    term_student_id: timetable.student_id
  }
end

File.open('term.json', 'w') do |file|
  file.write(term.to_json)
end
File.open('timetables.json', 'w') do |file|
  file.write(timetables.to_json)
end
File.open('teacher_optimization_rule.json', 'w') do |file|
  file.write(teacher_optimization_rule.to_json)
end
File.open('student_optimization_rules.json', 'w') do |file|
  file.write(student_optimization_rules.to_json)
end
File.open('term_teachers.json', 'w') do |file|
  file.write(term_teachers.to_json)
end
File.open('term_students.json', 'w') do |file|
  file.write(term_students.to_json)
end
File.open('term_tutorials.json', 'w') do |file|
  file.write(term_tutorials.to_json)
end
File.open('term_groups.json', 'w') do |file|
  file.write(term_groups.to_json)
end
File.open('student_vacancies.json', 'w') do |file|
  file.write(student_vacancies.to_json)
end
File.open('teacher_vacancies.json', 'w') do |file|
  file.write(teacher_vacancies.to_json)
end
File.open('tutorial_contracts.json', 'w') do |file|
  file.write(tutorial_contracts.to_json)
end
File.open('teacher_group_timetables.json', 'w') do |file|
  file.write(teacher_group_timetables.to_json)
end
File.open('student_group_timetables.json', 'w') do |file|
  file.write(student_group_timetables.to_json)
end
