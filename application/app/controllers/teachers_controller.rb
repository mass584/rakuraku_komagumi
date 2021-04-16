class TeachersController < ApplicationController
  PAGE_SIZE = 25

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!

  def index
    @keyword = sanitize_string_query_param(params[:keyword])
    @page = sanitize_integer_query_param(params[:page])
    @page_size = PAGE_SIZE
    @teachers = @room.teachers.active.ordered.matched(@keyword).pagenated(@page, @page_size)
  end

  def create
    @teacher = Teacher.new(create_params)
    respond_to do |format|
      if @teacher.save
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def update
    @teacher = Teacher.find(params[:id])
    respond_to do |format|
      if @teacher.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def destroy
    @teacher = Teacher.find(params[:id])
    respond_to do |format|
      if @teacher.update(is_deleted: true)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  private

  def create_params
    params.require(:teacher).permit(:room_id, :name, :email)
  end

  def update_params
    params.require(:teacher).permit(:name, :email)
  end
end
