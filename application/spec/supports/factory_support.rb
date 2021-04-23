module FactorySupport
  def create_normal_term
    room = FactoryBot.create(:room)
    term = FactoryBot.create(:first_term, room: room)
    FactoryBot.create_list(:tutorial, 5, room: term.room).map do |tutorial|
      FactoryBot.create(:term_tutorial, id: tutorial.id, term: term, tutorial: tutorial)
    end
    FactoryBot.create_list(:group, 2, room: term.room).map do |group|
      FactoryBot.create(:term_group, id: group.id, term: term, group: group)
    end
    term.reload
  end

  def create_season_term
    room = FactoryBot.create(:room)
    term = FactoryBot.create(:spring_term, room: room)
    FactoryBot.create_list(:tutorial, 5, room: term.room).map do |tutorial|
      FactoryBot.create(:term_tutorial, id: tutorial.id, term: term, tutorial: tutorial)
    end
    FactoryBot.create_list(:group, 2, room: term.room).map do |group|
      FactoryBot.create(:term_group, id: group.id, term: term, group: group)
    end
    term.reload
  end

  def create_exam_planning_term
    room = FactoryBot.create(:room)
    term = FactoryBot.create(:exam_planning_term, room: room)
    FactoryBot.create_list(:tutorial, 5, room: term.room).map do |tutorial|
      FactoryBot.create(:term_tutorial, id: tutorial.id, term: term, tutorial: tutorial)
    end
    FactoryBot.create_list(:group, 2, room: term.room).map do |group|
      FactoryBot.create(:term_group, id: group.id, term: term, group: group)
    end
    term.reload
  end

  def create_normal_term_with_teacher_and_student(teacher_count, student_count)
    term = create_normal_term
    FactoryBot.create_list(:teacher, teacher_count, room: term.room).map do |teacher|
      FactoryBot.create(:term_teacher, id: teacher.id, term: term, teacher: teacher)
    end
    FactoryBot.create_list(:student, student_count, room: term.room).map do |student|
      FactoryBot.create(:term_student, id: student.id, term: term, student: student)
    end
    term.reload
  end

  def create_normal_term_with_schedule
    term = create_normal_term
    tutorial_timetable = term.timetables.find_by(date_index: 1, period_index: 1)
    group_timetable = term.timetables.find_by(date_index: 1, period_index: 2)
    teacher = FactoryBot.create(:teacher, room: term.room)
    term_teacher = FactoryBot.create(:term_teacher, term: term, teacher: teacher)
    student = FactoryBot.create(:student, room: term.room)
    term_student = FactoryBot.create(:term_student, term: term, student: student)
    tutorial_contract = term_student.tutorial_contracts.first
    group_contract = term_student.group_contracts.first
    term_group = group_contract.term_group
    term_group.update(term_teacher: term_teacher)
    group_timetable.update(term_group_id: term_group.id)
    tutorial_contract.update(term_teacher: term_teacher, piece_count: 1)
    tutorial_piece = tutorial_contract.tutorial_pieces.first
    tutorial_piece.update(seat: tutorial_timetable.seats.first)
    group_contract.update(is_contracted: true)
    term.reload
  end

  def create_season_term_with_teacher_and_student(teacher_count, student_count)
    term = create_season_term
    FactoryBot.create_list(:teacher, teacher_count, room: term.room).map do |teacher|
      FactoryBot.create(:term_teacher, id: teacher.id, term: term, teacher: teacher)
    end
    FactoryBot.create_list(:student, student_count, room: term.room).map do |student|
      FactoryBot.create(:term_student, id: student.id, term: term, student: student)
    end
    term.reload
  end

  def create_exam_planning_term_with_teacher_and_student(teacher_count, student_count)
    term = create_exam_planning_term
    FactoryBot.create_list(:teacher, teacher_count, room: term.room).map do |teacher|
      FactoryBot.create(:term_teacher, id: teacher.id, term: term, teacher: teacher)
    end
    FactoryBot.create_list(:student, student_count, room: term.room).map do |student|
      FactoryBot.create(:term_student, id: student.id, term: term, student: student)
    end
    term.reload
  end

  def timetables(term)
    term.timetables.where(date_index: 1).order(period_index: 'ASC')
  end

  def seats(term)
    term.seats.joins(:timetable).where('timetables.date_index': 1, seat_index: 1).order(period_index: 'ASC')
  end

  def student_tutorial_contracts(term, term_student)
    term.tutorial_contracts.where(term_student: term_student)
  end

  def student_group_contracts(term, term_student)
    term.group_contracts.where(term_student: term_student)
  end
end