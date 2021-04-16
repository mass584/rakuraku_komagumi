class TermsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!, only: [:show]

  def index
    @terms = @room.terms.order(begin_at: 'DESC')
  end

  def create
    @term = Term.new(create_params)
    respond_to do |format|
      if @term.save
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def update
    @term = Term.find(params[:id])
    respond_to do |format|
      if @term.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def show
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

  def update_params
    params.require(:term).permit(:name, :year)
  end
end
