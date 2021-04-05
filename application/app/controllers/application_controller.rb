class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true

  private

  def term_selected?
    if !session[:term_id]
      redirect_to controller: :term, action: :index
    else
      @term = Term.find(session[:term_id])
    end
  end

  def sanitize_integer_query_param(value)
    value.present? ? value.to_i : nil
  end

  def sanitize_string_query_param(value)
    value.present? ? value.to_s : nil
  end

  def after_sign_in_path_for(_resource)
    '/rooms'
  end
end
