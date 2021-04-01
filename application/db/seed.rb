room = Room.create(name: '教室名')
term = Term.create(
  room_id: room.id,
  name: '１学期',
  year: 2020,
  term_type: 'normal',
  begin_at: '2020-04-13',
  end_at: '2020-07-26',
  period_count: 6,
  seat_count: 7,
  position_count: 2,
)
tutorial = Tutorial.create(room: room.id, name: '個別科目１', order: 1)
group = Group.create(room: room.id, name: '集団科目１', order: 1)
student = Student.create(
  room: room,
  name: '生徒１',
  email: 'student1@example.com',
  school_grade: 21,
)
teacher = Teacher.create(
  room: room,
  name: '講師１',
  email: 'teacher1@example.com',
)
term_tutorial = TermTutorial.create(term: term, tutorial: tutorial)
term_group = TermGroup.create(term: term, group: group)
term_student = TermStudent.create(term: term, student: student, school_grade: 21)
term_teacher = TermTeacher.create(term: term, teacher: teacher)
