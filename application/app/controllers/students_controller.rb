class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!

  def index
    @student_count = @room.students.active.count
    @keyword = sanitize_string_query_param(params[:keyword])
    @current_page = sanitize_integer_query_param(params[:page]) || 1
    @page_size = sanitize_integer_query_param(params[:page_size]) || 10
    @students = @room.students.active.ordered.matched(@keyword).pagenated(@current_page, @page_size)
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
    @student = Student.find_by(id: params[:id])
    respond_to do |format|
      if @student.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def destroy
    @student = Student.find_by(id: params[:id])
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
