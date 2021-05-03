class OptimizationLogsController < ApplicationController
  def create
    @optimization_log = OptimizationLog.new(create_params)
    if @optimization_log.save
      render json: @optimization_log.to_json, status: :created
    else
      render json: { message: @optimization_log.errors.full_messages }, status: :bad_request
    end
  end

  def update
    @optimization_log = OptimizationLog.find_by(id: params[:id])
    if @optimization_log.update(update_params)
      render json: @optimization_log.to_json, status: :ok
    else
      render json: { message: @optimization_log.errors.full_messages }, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:optimization_log).permit(:term_id)
  end

  def update_params
    params.require(:optimization_log).permit(
      :installation_progress,
      :swapping_progress,
      :deletion_progress,
      :exit_status,
    )
  end
end
