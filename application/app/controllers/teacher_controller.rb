class TeacherController < ApplicationController
  before_action :check_login

  def index
    @teachers = @room.exist_teachers
    @teacher = Teacher.new
  end

  def create
    @teacher = Teacher.new(teacher_create_params)
    respond_to do |format|
      if @teacher.save
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def update
    @teacher = Teacher.find(params[:id])
    respond_to do |format|
      if @teacher.update(teacher_update_params)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def destroy
    @teacher = Teacher.find(params[:id])
    respond_to do |format|
      if @teacher.update(is_deleted: true)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  private

  def teacher_create_params
    params.require(:teacher).permit(
      :room_id,
      :name,
      :name_kana,
      :email,
      :tel,
      :zip,
      :address,
    ).merge(
      is_deleted: false
    )
  end

  def teacher_update_params
    params.require(:teacher).permit(
      :name,
      :name_kana,
      :email,
      :tel,
      :zip,
      :address,
    )
  end
end
