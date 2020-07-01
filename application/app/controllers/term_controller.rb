class TermController < ApplicationController
  before_action :room_signed_in?

  def index
    @terms = @room.terms.order(begin_at: 'DESC')
    @term = Term.new
  end

  def create
    @term = Term.new(create_params)
    respond_to do |format|
      if @term.save
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def show
    session[:term_id] = params[:id]
    @term = Term.find(params[:id])
    @subject_term = SubjectTerm.new
    @student_term = StudentTerm.new
    @teacher_term = TeacherTerm.new
    if @term.idle?
      render 'schedulemaster/show_idle'
    else
      render 'schedulemaster/show_busy'
    end
  end

  def update
    record = Term.find(params[:id])
    respond_to do |format|
      if record.update(update_params)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def destroy
    record = Term.find(params[:id])
    respond_to do |format|
      if record.destroy
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  private

  def create_params
    params.require(:term).permit(
      :room_id,
      :name,
      :type,
      :year,
      :begin_at,
      :end_at,
      :max_period,
      :max_seat,
      :max_piece,
    )
  end

  def update_params
    params.require(:term).permit(:name)
  end
end
