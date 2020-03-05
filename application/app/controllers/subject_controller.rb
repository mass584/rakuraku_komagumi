class SubjectController < ApplicationController
  include RoomStore
  before_action :check_logined
  helper_method :room

  def index
    @subjects = room.exist_subjects.rank(:row_order)
  end

  def new
    @subject = Subject.new
  end

  def create
    @subject = Subject.new(subject_params)
    respond_to do |format|
      if @subject.save
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def edit
    @subject = Subject.find(params[:id])
  end

  def update
    @subject = Subject.find(params[:id])
    respond_to do |format|
      if @subject.update(subject_params)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def destroy
    @subject = Subject.find(params[:id])
    @subject.update(is_deleted: true)
    redirect_to action: :index
  end

  private

  def subject_params
    params.require(:subject).permit(
      :name,
      :classtype,
      :room_id,
      :row_order,
    )
  end
end
