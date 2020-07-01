class SubjectTermController < ApplicationController
  before_action :room_signed_in?
  before_action :term_selected?

  def create
    subject = Subject.find_by(id: params[:subject_id])
    respond_to do |format|
      if SubjectTerm.additional_create(subject, @term)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end
end
