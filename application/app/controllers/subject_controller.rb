class SubjectController < ApplicationController
  before_action :authenticate_room!

  def index
    respond_to do |format|
      format.html do
        @subjects = current_room.subjects.active.sorted
        @subject = Subject.new
      end
      format.json do
        render json: current_room.exist_subjects.to_json
      end
    end
  end

  def create
    @subject = Subject.new(create_params)
    respond_to do |format|
      if @subject.save
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def update
    @subject = Subject.find(params[:id])
    respond_to do |format|
      if @subject.update(update_params)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def destroy
    @subject = Subject.find(params[:id])
    respond_to do |format|
      if @subject.update(is_deleted: true)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  private

  def create_params
    params.require(:subject).permit(
      :name,
      :room_id,
      :order,
    )
  end

  def update_params
    params.require(:subject).permit(
      :name,
      :order,
    )
  end
end
