class SubjectController < ApplicationController
  before_action :room_signed_in?

  def index
    @subjects = current_room.exist_subjects
    @subject = Subject.new
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
    ).merge(
      is_deleted: false,
    )
  end

  def update_params
    params.require(:subject).permit(
      :name,
      :order,
    )
  end
end
