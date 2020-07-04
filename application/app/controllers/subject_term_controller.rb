class SubjectTermController < ApplicationController
  before_action :room_signed_in?
  before_action :term_selected?

  def create
    @subject_term = SubjectTerm.new(create_params)
    if @subject_term.save_with_contract
      render 'subject_term/create'
    end
  end

  private

  def create_params
    params.require(:subject_term).permit(
      :subject_id,
    ).merge({
      term_id: @term.id,
    })
  end
end
