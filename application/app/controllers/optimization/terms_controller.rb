module Optimization
  class TermsController < OptimizationController
    def show
      term = Term.find_by(id: params[:id])
      render json: term, serializer: OptimizationTermSerializer, status: :ok, key_transform: :unaltered
    end

    def update
      term = TermOverallSchedule.new(update_params)
      if term.save
        head :no_content
      else
        render status: 400, json: bad_request(term)
      end
    end

    private

    def update_params
      params.require(:term).permit(tutorial_pieces: [], seats: []).merge(term_id: params[:id])
    end
  end
end
