class TermsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms!
  before_action :set_room!
  before_action :set_term!, only: [:show, :schedule]

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
    @term = Term.find_by(id: params[:id])
    respond_to do |format|
      if @term.update(update_params)
        format.js { @success = true }
      else
        format.js { @success = false }
      end
    end
  end

  def show
    @teacher_optimization_rule = TeacherOptimizationRule.find_by(term_id: @term.id)
    @student_optimization_rules = StudentOptimizationRule.ordered.filtered.where(term_id: @term.id)
    @term_tutorials = @term.term_tutorials.named
    @term_groups = @term.term_groups.named
  end

  def schedule
    @tutorial_pieces = TutorialPiece.indexed_and_named.where(term_id: @term.id)
    @seats = Seat.with_group.with_timetable.with_term_teacher.where(term_id: @term.id)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = OverlookSchedule.new(@term, @tutorial_pieces, @seats).render
        filename = "#{@room.name}_#{@term.year}年度_#{@term.name}_全体予定表.pdf"
        send_data pdf, filename: filename, type: 'application/pdf', disposition: 'inline'
      end
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

  def update_params
    params.require(:term).permit(:name, :year)
  end
end
