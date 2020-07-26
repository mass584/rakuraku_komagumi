class SubjectTermController < ApplicationController
  before_action :authenticate_room!
  before_action :term_selected?

  def create
    @subject_term = SubjectTerm.new(create_params)
    respond_to do |format|
      if @subject_term.save
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  private

  def create_params
    params.require(:subject_term).permit(:subject_id).merge({ term_id: @term.id })
  end
end
