class StudentsController < ApplicationController
  PAGE_SIZE = 25

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!

  def index
    @keyword = sanitize_string_query_param(params[:keyword])
    @page = sanitize_integer_query_param(params[:page])
    @page_size = PAGE_SIZE
    @students = @room.students.active.ordered.matched(@keyword).pagenated(@page, @page_size)
  end

  def create
    @student = Student.new(create_params)
    respond_to do |format|
      if @student.save
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def update
    @student = Student.find(params[:id])
    respond_to do |format|
      if @student.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def destroy
    @student = Student.find(params[:id])
    respond_to do |format|
      if @student.update(is_deleted: true)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  private

  def create_params
    params.require(:student).permit(:room_id, :name, :school_grade, :email)
  end

  def update_params
    params.require(:student).permit(:name, :school_grade, :email)
  end
end
