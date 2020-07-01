class TeacherController < ApplicationController
  before_action :room_signed_in?

  def index
    @teachers = @room.exist_teachers
    @teacher = Teacher.new
  end

  def create
    @teacher = Teacher.new(create_params)
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
      if @teacher.update(update_params)
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

  def create_params
    params.require(:teacher).permit(
      :room_id,
      :name,
      :name_kana,
      :email,
      :tel,
      :zip,
      :address,
    ).merge(
      is_deleted: false,
    )
  end

  def update_params
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
