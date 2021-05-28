class TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!

  def index
    @teacher_count = @room.teachers.active.count
    @keyword = sanitize_string_query_param(params[:keyword])
    @current_page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = sanitize_integer_query_param(params[:page_size]) || 10
    @teachers = @room.teachers.active.ordered.matched(@keyword).pagenated(@current_page, @page_size)
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
    @teacher = Teacher.find_by(id: params[:id])
    respond_to do |format|
      if @teacher.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def destroy
    @teacher = Teacher.find_by(id: params[:id])
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
