class TutorialsController < ApplicationController
  PAGE_SIZE = 10

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!

  def index
    @tutorials = @room.tutorials.active.ordered
  end

  def create
    @tutorial = Tutorial.new(create_params)
    respond_to do |format|
      if @tutorial.save
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def update
    @tutorial = Tutorial.find_by(id: params[:id])
    respond_to do |format|
      if @tutorial.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def destroy
    @tutorial = Tutorial.find_by(id: params[:id])
    respond_to do |format|
      if @tutorial.update(is_deleted: true)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  private

  def create_params
    params.require(:tutorial).permit(:room_id, :name, :short_name, :order)
  end

  def update_params
    params.require(:tutorial).permit(:name, :short_name, :order)
  end
end
