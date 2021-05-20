class TermOverallSchedulesController < ApplicationController
  before_action :basic_auth

  def create
    record = TermOverallSchedule.new(create_params)
    if record.save
      head :no_content
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:term_overall_schedule).permit(:term_id, tutorial_pieces: [], seats: [])
  end
end
