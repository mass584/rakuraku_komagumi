class TutorialPiecesController < ApplicationController
  PAGE_SIZE = 7

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    respond_to do |format|
      format.json do
        term = Term.cache_child_models.find_by(id: @term.id)
        render json: term, serializer: TermSerializer, status: :ok
      end
      format.html
      format.pdf do
        pdf = OverlookSchedule.new(@term).render
        filename = "#{@room.name}_#{@term.year}年度_#{@term.name}_全体予定表.pdf"
        send_data pdf, filename: filename, type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def update
    record = TutorialPiece.find_by(id: params[:id])
    if record.update(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  def bulk_update
    records = @term.tutorial_pieces.filter_by_placed
    if records.update_all(bulk_update_params.to_h)
      head :no_content
    else
      render json: { message: records.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:tutorial_piece).permit(:is_fixed, :seat_id)
  end

  def bulk_update_params
    params.require(:tutorial_piece).permit(:is_fixed, :seat_id)
  end
end
