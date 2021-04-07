class TutorialPiecesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    @page = sanitize_integer_query_param(params[:page]) || 1
    respond_to do |format|
      format.json do
        @records = @term.tutorial_pieces
        render 'index', formats: :json, handlers: 'jbuilder'
      end
      format.html do
      end
      format.pdf do
        seats = Seat.get_seats(@term)
        pieces = Piece.get_pieces(@term)
        begin_end_times = BeginEndTime.get_begin_end_times(@term)
        pdf = OverlookSchedule.new(@term, seats, pieces, begin_end_times).render
        send_data pdf,
                  filename: "#{@term.name}予定表.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def update
    record = Piece.find(params[:id])
    if record.update(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  def bulk_update
    records = @term.pieces.where.not(seat_id: nil)
    if records.update_all(bulk_update_params)
      render json: {}, status: :no_content
    else
      render json: { message: records.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:piece).permit(:seat_id, :is_fixed)
  end

  def bulk_update_params
    params.require(:piece).permit(:is_fixed)
  end
end
