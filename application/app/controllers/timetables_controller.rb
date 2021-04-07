class TimetablesController < ApplicationController
  PAGE_SIZE = 7

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = PAGE_SIZE
    @date_index_array = current_term.date_index_array(@page)
    @period_index_array = current_term.period_index_array
    @timetables = current_term.timetables
    @begin_end_times = current_term.begin_end_times
    @term_groups = current_term.term_groups.joins(:group).select('term_groups.id', 'groups.name')
  end

  def update
    record = Timetable.find(params[:id])
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
