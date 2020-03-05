module Mapping
  def associate_teacher_to_schedulemaster(teacher_id, schedulemaster_id)
    record = TeacherSchedulemasterMapping.new(
      schedulemaster_id: schedulemaster_id,
      teacher_id: teacher_id,
    )
    record.save
  end

  def associate_student_to_schedulemaster(student_id, schedulemaster_id)
    grade = Student.find(student_id).grade
    record = StudentSchedulemasterMapping.new(
      schedulemaster_id: schedulemaster_id,
      student_id: student_id,
      grade: grade,
    )
    record.save
  end

  def associate_subject_to_schedulemaster(subject_id, schedulemaster_id)
    record = SubjectSchedulemasterMapping.new(
      schedulemaster_id: schedulemaster_id,
      subject_id: subject_id,
    )
    record.save
  end
end
