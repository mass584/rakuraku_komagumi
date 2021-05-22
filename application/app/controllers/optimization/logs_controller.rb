module Optimization
  class LogsController < OptimizationController
    def update
      optimization_log = OptimizationLog.find_by(id: params[:id])
      if optimization_log.update(update_params)
        head :no_content
      else
        render status: 400, json: bad_request(term)
      end
    end

    private

    def update_params
      params.require(:optimization_log).permit(
        :sequence_number,
        :installation_progress,
        :swapping_progress,
        :deletion_progress,
        :exit_status,
        :exit_message,
      )
    end
  end
end
