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