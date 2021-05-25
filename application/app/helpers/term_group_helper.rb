module TermGroupHelper
  def options_for_select_group_id(room, term)
    plucked_groups = room.groups.active.pluck(:name, :id)
    plucked_term_groups = term.term_groups.ordered.named.pluck(:name, :group_id)
    plucked_groups - plucked_term_groups
  end

  def options_for_select_term_teacher_ids(term)
    term.term_teachers.named.select(:name, :id).pluck(:name, :id)
  end
end
