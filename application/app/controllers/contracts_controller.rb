class ContractsController < ApplicationController
  PAGE_SIZE = 10

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = PAGE_SIZE
    @term_students = current_term.term_students.ordered.pagenated(@page, @page_size).joins(:student).select('term_students.id', 'students.name', 'term_students.school_grade')
    @term_students_count = current_term.term_students.count
    @term_teachers = current_term.term_teachers.joins(:teacher).select('term_teachers.id', 'teachers.name')
    @term_tutorials = current_term.term_tutorials.ordered.joins(:tutorial).select('term_tutorials.id', 'tutorials.name')
    @term_groups = current_term.term_groups.ordered.joins(:group).select('term_groups.id', 'groups.name')
    @tutorial_contracts = current_term.tutorial_contracts
    @group_contracts = current_term.group_contracts
  end
end
