class TeacherOptimizationRulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def update
    @teacher_optimization_rule = TeacherOptimizationRule.find_by(id: params[:id])
    respond_to do |format|
      if @teacher_optimization_rule.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  private

  def update_params
    params.require(:teacher_optimization_rule).permit(
      :single_cost,
      :different_pair_cost,
      :occupation_limit,
      :occupation_costs,
      :blank_limit,
      :blank_costs,
    )
  end
end
