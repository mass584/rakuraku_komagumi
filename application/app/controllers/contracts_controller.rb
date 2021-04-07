class ContractsController < ApplicationController
  PAGE_SIZE = 25

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = PAGE_SIZE
    @tutorial_contracts = TutorialContract.tutorial_contracts_group_by_student_and_tutorial(current_term)
    @group_contracts = GroupContract.group_contracts_group_by_student_and_group(current_term)
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
