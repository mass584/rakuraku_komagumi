json.array! @records do |record|
  json.id record.id
  json.number record.number
  json.date record.timetable.date
  json.period record.timetable.period
  json.teacher_term_id record.teacher_term_id
  json.teacher_name record.teacher_term&.teacher&.name
  json.student_requests do
    json.array! record.timetable.student_requests.map(&:student_term_id)
  end
  json.teacher_requests do
    json.array! record.timetable.teacher_requests.map(&:teacher_term_id)
  end
end