class OptimizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @teacher_optimization_rule = TeacherOptimizationRule.find_by(term_id: @term.id)
    @student_optimization_rules = StudentOptimizationRule.ordered.where(term_id: @term.id)
  end
end
