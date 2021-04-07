module TermTutorialHelper
  def options_for_select_tutorial_id(room, term)
    plucked_tutorials = room.tutorials.active.pluck(:name, :id) 
    plucked_term_tutorials = term.term_tutorials.ordered.joins(:tutorial).pluck('tutorials.name', :tutorial_id)
    plucked_tutorials - plucked_term_tutorials
  end
end
