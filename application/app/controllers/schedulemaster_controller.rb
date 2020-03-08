class SchedulemasterController < ApplicationController
  require './app/pdfs/pdf_overlook_schedule'
  before_action :check_login

  def index
    @schedulemasters = @room.schedulemasters.order(begin_at: 'DESC')
    @schedulemaster = Schedulemaster.new
  end

  def create
    @schedulemaster = Schedulemaster.new(schedulemaster_create_params)
    respond_to do |format|
      if @schedulemaster.save
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def show
    session[:schedulemaster_id] = params[:id]
    @schedulemaster = Schedulemaster.find(params[:id])
    @subject_schedulemaster_mapping = SubjectSchedulemasterMapping.new
    @student_schedulemaster_mapping = StudentSchedulemasterMapping.new
    @teacher_schedulemaster_mapping = TeacherSchedulemasterMapping.new
    if @schedulemaster.idle?
      render('schedulemaster/show_idle') && return
    else
      render('schedulemaster/show_busy') && return
    end
  end

  def update
    @schedulemaster = Schedulemaster.find(params[:id])
    respond_to do |format|
      if @schedulemaster.update(schedulemaster_update_params)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def destroy
    @schedulemaster = Schedulemaster.find(params[:id])
    respond_to do |format|
      if @schedulemaster.destroy
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def overlook
    pdf = PdfOverlookSchedule.new(@schedulemaster.id).render
    send_data pdf,
              filename: 'OverlookSchedule.pdf',
              type: 'application/pdf',
              disposition: 'inline'
  end

  private

  def schedulemaster_create_params
    params.require(:schedulemaster).permit(
      :room_id,
      :name,
      :type,
      :year,
      :begin_at,
      :end_at,
      :max_period,
      :max_seat,
      :class_per_teacher
    ).merge(
      batch_status: 0
    )
  end

  def schedulemaster_update_params
    params.require(:schedulemaster).permit(
      :batch_status
    )
  end
end
