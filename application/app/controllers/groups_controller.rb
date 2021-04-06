class GroupsController < ApplicationController
  PAGE_SIZE = 10

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!

  def index
    @keyword = sanitize_string_query_param(params[:keyword])
    @page = sanitize_integer_query_param(params[:page])
    @page_size = PAGE_SIZE
    @groups = current_room.groups.active.ordered
  end

  def create
    @group = Group.new(create_params)
    respond_to do |format|
      if @group.save
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def update
    @group = Group.find(params[:id])
    respond_to do |format|
      if @group.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    respond_to do |format|
      if @group.update(is_deleted: true)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  private

  def create_params
    params.require(:group).permit(:room_id, :name, :order)
  end

  def update_params
    params.require(:group).permit(:name, :order)
  end
end
