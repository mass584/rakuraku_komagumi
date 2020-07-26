class ContractController < ApplicationController
  before_action :authenticate_room!
  before_action :term_selected?

  def index
    @contracts = Contract.get_contracts(@term.id)
    @page = params[:page].to_i || 1
  end

  def update
    record = Contract.find(params[:id])
    if record.update(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:contract).permit(:teacher_term_id, :count)
  end
end
