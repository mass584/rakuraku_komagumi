class StudentController < ApplicationController
  before_action :check_login

  def index
    @students = @room.exist_students
    @student = Student.new
  end

  def create
    @student = Student.new(student_create_params)
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
      if @student.update(student_update_params)
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

  def student_create_params
    params.require(:student).permit(
      :room_id,
      :name,
      :name_kana,
      :gender,
      :birth_year,
      :school,
      :email,
      :tel,
      :zip,
      :address,
    ).merge(
      is_deleted: false
    )
  end

  def student_update_params
    params.require(:student).permit(
      :name,
      :name_kana,
      :gender,
      :birth_year,
      :school,
      :email,
      :tel,
      :zip,
      :address,
    )
  end
end
