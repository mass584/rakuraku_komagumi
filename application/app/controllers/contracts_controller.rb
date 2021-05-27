class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @term_students_count = @term.term_students.count
    @current_page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = sanitize_integer_query_param(params[:page_size]) || 10
    @term_students = @term.term_students.ordered.pagenated(@current_page, @page_size).named
    @term_teachers = @term.term_teachers.named
    @term_tutorials = @term.term_tutorials.ordered.named
    @term_groups = @term.term_groups.ordered.named
    @tutorial_contracts = @term.tutorial_contracts
    @group_contracts = @term.group_contracts
  end
end
