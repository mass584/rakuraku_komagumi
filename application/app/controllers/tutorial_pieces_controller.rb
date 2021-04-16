class TutorialPiecesController < ApplicationController
  PAGE_SIZE = 7

  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!

  def index
    respond_to do |format|
      format.json do
        term = Term
          .preload(term_teachers: :teacher)
          .preload(timetables: [
            { term_group: [:group, :group_contracts] },
            { seats: { tutorial_pieces: :tutorial_contract } },
            :teacher_vacancies,
            :student_vacancies,
          ])
          .preload(tutorial_pieces: [
            {
              tutorial_contract: [
                { term_tutorial: :tutorial },
                { term_student: :student },
              ],
            },
          ])
          .find_by(id: @term.id)
        render json: term, serializer: TermSerializer, status: :ok
      end
      format.html do
      end
      format.pdf do
        pdf = OverlookSchedule.new(@term).render
        filename = "#{@room.name}_#{@term.year}年度_#{@term.name}_全体予定表.pdf"
        send_data pdf, filename: filename, type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def update
    record = TutorialPiece.find(params[:id])
    if record.update(update_params)
      render json: record.to_json, status: :ok
    else
      render json: { message: record.errors.full_messages }, status: :bad_request
    end
  end

  def bulk_update
    records = @term.pieces.where.not(seat_id: nil)
    if records.update_all(bulk_update_params)
      head :no_content
    else
      render json: { message: records.errors.full_messages }, status: :bad_request
    end
  end

  def bulk_reset
    records = @term.pieces
    if records.update_all(seat_id: nil, is_fixed: false)
      head :no_content
    else
      render json: { message: records.errors.full_messages }, status: :bad_request
    end
  end

  private

  def update_params
    params.require(:tutorial_piece).permit(:seat_id, :is_fixed)
  end

  def bulk_update_params
    params.require(:tutorial_piece).permit(:is_fixed)
  end
end
