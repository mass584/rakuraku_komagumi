class TeacherController < ApplicationController
  before_action :check_login

  def index
    @subject = @room.exist_subjects
    @teacher = @room.exist_teachers
  end

  def new
    @teacher = Teacher.new
  end

  def create
    @teacher = Teacher.new(teacher_params)
    if @teacher.save
      @subject = @room.exist_subjects
      @status = 'success'
    else
      @status = 'fail'
    end
  end

  def edit
    @teacher = Teacher.find(params[:id])
  end

  def update
    @teacher = Teacher.find(params[:id])
    @status = @teacher.update(teacher_params)
  end

  def destroy
    @teacher = Teacher.find(params[:id])
    @teacher.update(is_deleted: true)
    redirect_to action: :index
  end

  private

  def teacher_params
    params.require(:teacher).permit(
      :room_id,
      :name,
      :name_kana,
      :email,
      :tel,
      :zip,
      :address,
    )
  end
end
