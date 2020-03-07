class SubjectController < ApplicationController
  before_action :check_login

  def index
    @subjects = @room.exist_subjects
    @subject = Subject.new
  end

  def create
    @subject = Subject.new(subject_create_params)
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
      if @subject.update(subject_update_params)
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

  def subject_create_params
    params.require(:subject).permit(
      :name,
      :room_id,
      :order
    ).merge(
      is_deleted: false
    )
  end

  def subject_update_params
    params.require(:subject).permit(
      :name,
      :order
    )
  end
end
