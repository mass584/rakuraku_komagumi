class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true

  private

  def set_rooms!
    @rooms = Room.ordered.all
  end

  def current_room(room_id)
    Room.find_by(id: room_id) || Room.new
  end

  def set_room!
    room_id = sanitize_integer_query_param(params[:room_id]) || cookies[:room_id]
    @room = current_room(room_id)
    cookies[:room_id] = room_id
  end

  def current_term(term_id)
    @room.terms.find_by(id: term_id)
  end

  def set_term!
    term_id = sanitize_integer_query_param(params[:term_id]) || cookies[:term_id]
    @term = current_term(term_id)
    redirect_to terms_path if @term.nil?
    cookies[:term_id] = term_id
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
