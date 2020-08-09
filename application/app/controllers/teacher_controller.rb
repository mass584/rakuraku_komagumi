class TeacherController < ApplicationController
  before_action :authenticate_room!

  def index
    respond_to do |format|
      format.html do
        @teachers = current_room.exist_teachers
        @teacher = Teacher.new
      end
      format.json do
        render json: current_room.exist_teachers.to_json
      end
    end
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
