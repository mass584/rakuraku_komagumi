class StudentController < ApplicationController
  before_action :check_login

  def index
    @students = @room.exist_students
    @subjects = @room.exist_subjects
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)
    if @student.save
      @subject = @room.exist_subjects
      @status = 'success'
    else
      @status = 'fail'
    end
  end

  def edit
    @student = Student.find(params[:id])
  end

  def update
    @student = Student.find(params[:id])
    @status = @student.update(student_params)
  end

  def destroy
    @student = Student.find(params[:id])
    @student.update(is_deleted: true)
    redirect_to action: :index
  end

  private

  def student_params
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
    )
  end
end
