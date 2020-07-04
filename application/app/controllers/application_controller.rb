class ApplicationController < ActionController::Base
  private

  def term_selected?
    if !session[:term_id]
      redirect_to controller: :term, action: :index
    else
      @term = Term.find(session[:term_id])
    end
  end

  def after_sign_in_path_for(_resource)
    '/term'
  end
end
