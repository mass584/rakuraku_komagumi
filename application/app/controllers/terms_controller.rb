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
    @tutorial_pieces = TutorialPiece.joins(
      tutorial_contract: [
        term_student: [:student],
        term_tutorial: [:tutorial],
        term_teacher: [:teacher]
      ],
      seat: :timetable,
    ).where(
      'term_students.id': params[:term_student_id],
    ).select(
      :date_index,
      :period_index,
      :seat_index,
      'students.name AS student_name',
      'tutorials.name AS tutorial_name',
      'teachers.name AS teacher_name',
    )
    @seats = Seat.joins(
      timetable: [term_group: [:group]],
    ).where(term_id: @term.id).select(
      :date_index,
      :period_index,
      :seat_index,
      :term_group_id,
      :is_closed,
      'groups.name AS group_name',
    )
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
