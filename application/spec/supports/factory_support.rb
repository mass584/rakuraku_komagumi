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
end