module Optimization
  class TermsController < OptimizationController
    def show
      term = Term.find_by(id: params[:id])
      render json: term, serializer: OptimizationTermSerializer, status: :ok
    end

    def update
      term = TermOverallSchedule.new(update_params)
      if term.save
        head :no_content
      else
        render status: 400, json: bad_request(term)
      end
    end

    def update_log
      optimization_log = OptimizationLog.find_by(id: params[:id])
      if optimization_log.update(update_params)
        head :no_content
      else
        render status: 400, json: bad_request(term)
      end
    end

    private

    def update_params
      params.require(:term).permit(tutorial_pieces: [], seats: [])
    end

    def update_log_params
      params.require(:optimization_log).permit(
        :installation_progress,
        :swapping_progress,
        :deletion_progress,
        :exit_status,
        :exit_message,
      )
    end
  end
end
