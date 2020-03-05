class StudentController < ApplicationController
  include RoomStore
  before_action :check_logined
  helper_method :room

  def index
    @student = room.exist_students
    @subject = room.exist_subjects
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)
    if @student.save
      @subject = room.exist_subjects
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
    @status = if @student.update(student_params)
                'success'
              else
                'fail'
              end
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
      :firstname,
      :lastname,
      :firstname_kana,
      :lastname_kana,
      :gender,
      :grade,
      :school,
      :zip,
      :address,
      :mail,
      :tel,
    )
  end
end
