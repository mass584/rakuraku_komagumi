module FactorySupport
  def create_normal_term
    room = FactoryBot.create(:room)
    term = FactoryBot.create(:first_term, room: room)
    FactoryBot.create_list(:tutorial, 5, room: room).map do |tutorial|
      FactoryBot.create(:term_tutorial, id: tutorial.id, term: term, tutorial: tutorial)
    end
    FactoryBot.create_list(:group, 2, room: room).map do |group|
      FactoryBot.create(:term_group, id: group.id, term: term, group: group)
    end
    term
  end

  def create_season_term
    room = FactoryBot.create(:room)
    term = FactoryBot.create(:spring_term, room: room)
    FactoryBot.create_list(:tutorial, 5, room: room).map do |tutorial|
      FactoryBot.create(:term_tutorial, id: tutorial.id, term: term, tutorial: tutorial)
    end
    FactoryBot.create_list(:group, 2, room: room).map do |group|
      FactoryBot.create(:term_group, id: group.id, term: term, group: group)
    end
    term
  end

  def create_exam_planning_term
    room = FactoryBot.create(:room)
    term = FactoryBot.create(:exam_planning_term, room: room)
    FactoryBot.create_list(:tutorial, 5, room: room).map do |tutorial|
      FactoryBot.create(:term_tutorial, id: tutorial.id, term: term, tutorial: tutorial)
    end
    FactoryBot.create_list(:group, 2, room: room).map do |group|
      FactoryBot.create(:term_group, id: group.id, term: term, group: group)
    end
    term
  end
end