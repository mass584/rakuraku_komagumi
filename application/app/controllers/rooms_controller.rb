class RoomsController < ApplicationController
  PAGE_SIZE = 10

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!

  def index
    @keyword = sanitize_string_query_param(params[:keyword])
    @page = sanitize_integer_query_param(params[:page])
    @page_size = PAGE_SIZE
    @rooms = Room.ordered.matched(@keyword).pagenated(@page, @page_size)
  end
end
