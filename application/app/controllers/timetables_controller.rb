class TimetablesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @timetables = @term.timetables
    @begin_end_times = @term.begin_end_times
    @term_groups = @term.term_groups.named
  end

  def update
    record = Timetable.find_by(id: params[:id])
    if record.update(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:timetable).permit(:is_closed, :term_group_id)
  end
end
