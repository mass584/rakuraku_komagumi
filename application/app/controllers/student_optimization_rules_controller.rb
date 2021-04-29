class StudentOptimizationRulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def update
    @student_optimization_rule = StudentOptimizationRule.find_by(id: params[:id])
    respond_to do |format|
      if @student_optimization_rule.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  private

  def update_params
    params.require(:student_optimization_rule).permit(
      :occupation_limit,
      :occupation_costs,
      :blank_limit,
      :blank_costs,
      :interval_cutoff,
      :interval_costs,
    )
  end
end
