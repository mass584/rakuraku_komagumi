class TermGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def create
    @term_group = TermGroup.new(create_params)
    respond_to do |format|
      if @term_group.save
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def update
    @term_group = TermGroup.find_by(id: params[:id])
    respond_to do |format|
      if @term_group.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  private

  def create_params
    params.require(:term_group).permit(:term_id, :group_id)
  end

  def update_params
    params.require(:term_group).permit(:term_teacher_id)
  end
end
