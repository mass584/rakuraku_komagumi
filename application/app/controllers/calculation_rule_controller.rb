class CalculationRuleController < ApplicationController
  include RoomStore
  include SchedulemasterStore
  before_action :check_logined
  before_action :check_schedulemaster
  helper_method :room
  helper_method :schedulemaster

  def edit
    @readonly = schedulemaster.schedules.where.not(timetable_id: 0).count.positive?
    @calculation_rule = CalculationRule.find(params[:id])
  end

  def update
    @calculation_rule = CalculationRule.find(params[:id])
    @status = if @calculation_rule.update(calculation_rule_params)
                'success'
              else
                'fail'
              end
  end

  private

  def calculation_rule_params
    params.require(:calculation_rule).permit(
      :single_cost,
      :different_pair_cost,
      :blank_class_cost,
      :blank_class_max,
      :total_class_cost,
      :total_class_max,
      :interval_cost,
    )
  end
end
