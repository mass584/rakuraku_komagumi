class OptimizationLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def update
    @optimization_log = OptimizationLog.find_by(id: params[:id])
    if @optimization_log.update(update_params)
      render json: @optimization_log.to_json, status: :ok
    else
      render json: { message: @optimization_log.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:optimization_log).permit(
      :installation_progress,
      :swapping_progress,
      :deletion_progress,
      :exit_status,
    )
  end
end
