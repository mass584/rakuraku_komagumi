class TermTutorialsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def create
    @term_tutorial = TermTutorial.new(create_params)
    respond_to do |format|
      if @term_tutorial.save
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  private

  def create_params
    params.require(:term_tutorial).permit(:term_id, :tutorial_id)
  end
end
