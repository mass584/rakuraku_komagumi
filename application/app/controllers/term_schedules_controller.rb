class TermSchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def create
    record = TermSchedule.new(create_params)
    if record.save
      head :no_content
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:term_schedule).permit(:tutorial_piece_id, :seat_id)
  end
end
