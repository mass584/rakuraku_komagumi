json.array! @records do |record|
  json.id record.id
  json.is_fixed record.is_fixed
  json.student_term_id record.contract.student_term_id
  json.student_name record.contract.student_term.student.name
  json.subject_term_id record.contract.subject_term_id
  json.subject_name record.contract.subject_term.subject.name
  json.seat_id record.seat_id
  json.date record.seat&.timetable&.date
  json.period record.seat&.timetable&.period
  json.teacher_term_id record.seat&.teacher_term_id
  json.teacher_name record.seat&.teacher_term&.teacher&.name
end
