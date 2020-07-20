class ContractController < ApplicationController
  before_action :room_signed_in?
  before_action :term_selected?

  def index
    @contracts = Contract.get_contracts(@term.id)
  end

  def update
    contract = Contract.find(params[:id])
    if contract.update(update_params)
      render json: {}, status: :ok
    else
      render json: { message: contract.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:contract).permit(:teacher_term_id, :count)
  end
end
