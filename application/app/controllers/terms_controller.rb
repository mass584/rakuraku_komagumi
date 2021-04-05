class TermsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room!
  before_action :set_term!, except: [:index]

  def index
    @terms = current_room.terms.order(begin_at: 'DESC')
  end

  def show
    @term = current_term
  end

  def new
    @term = Term.new
  end

  def create
    @term = Term.new(create_params)
    if @term.save
      redirect_to term_path(@term, { term_id: @term.id })
    else
      render action: :new
    end
  end

  protected

  def create_params
    params.require(:term).permit(
      :room_id,
      :name,
      :term_type,
      :year,
      :begin_at,
      :end_at,
      :period_count,
      :seat_count,
      :position_count,
    )
  end
end
