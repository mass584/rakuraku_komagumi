class StudentController < ApplicationController
  before_action :authenticate_room!

  def index
    respond_to do |format|
      format.html do
        page = params[:page] ? params[:page].to_i : 1
        @keyword = params[:keyword]
        @active_students = current_room.students.active.matched(@keyword)
        @students = @active_students.sorted.paginated(page)
      end
      format.json do
        render json: current_room.students.active.to_json
      end
    end
  end

  def create
    @student = Student.new(create_params)
    respond_to do |format|
      if @student.save
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def update
    @student = Student.find(params[:id])
    respond_to do |format|
      if @student.update(update_params)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def destroy
    @student = Student.find(params[:id])
    respond_to do |format|
      if @student.update(is_deleted: true)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  private

  def create_params
    params.require(:student).permit(
      :room_id,
      :name,
      :name_kana,
      :gender,
      :school_name,
      :school_grade,
      :email,
      :tel,
      :zip,
      :address,
    )
  end

  def update_params
    params.require(:student).permit(
      :name,
      :name_kana,
      :gender,
      :school_name,
      :school_grade,
      :email,
      :tel,
      :zip,
      :address,
    )
  end
end
