class StudentController < ApplicationController
  before_action :authenticate_room!

  def index
    respond_to do |format|
      format.html do
        @students = current_room.exist_students
        @student = Student.new
      end
      format.json do
        render json: current_room.exist_stuents.to_json
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
      :birth_year,
      :school_name,
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
      :birth_year,
      :school_name,
      :email,
      :tel,
      :zip,
      :address,
    )
  end
end
