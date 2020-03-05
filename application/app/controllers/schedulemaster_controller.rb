class SchedulemasterController < ApplicationController
  include RoomStore
  include SchedulemasterStore
  require 'open3'
  require './app/pdf/pdf_overlook_schedule'
  before_action :check_logined
  helper_method :room
  helper_method :schedulemaster

  def index
    @schedulemasters = room.schedulemasters.order(begindate: 'DESC')
  end

  def new
    @schedulemaster = Schedulemaster.new
  end

  def create
    @schedulemaster = Schedulemaster.new(schedulemaster_create_params)
    schedulemaster.calculation_status = 0
    schedulemaster.max_count = 50
    schedulemaster.max_time_sec = 0
    room = Room.find_by(login_id: session[:login_id])
    respond_to do |format|
      if schedulemaster.save
        CalculationRule.bulk_create(schedulemaster)
        TeacherSchedulemasterMapping.bulk_create(room, schedulemaster)
        StudentSchedulemasterMapping.bulk_create(room, schedulemaster)
        SubjectSchedulemasterMapping.bulk_create(room, schedulemaster)
        Timetablemaster.bulk_create(schedulemaster)
        Timetable.bulk_create(schedulemaster)
        Classnumber.bulk_create(schedulemaster)
        Teacherrequestmaster.bulk_create(schedulemaster)
        Studentrequestmaster.bulk_create(schedulemaster)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def show
    session[:schedulemaster_id] = params[:id]
    if schedulemaster.calculation_status == 1
      render('schedulemaster/show_busy') && return
    else
      render('schedulemaster/show') && return
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if schedulemaster.update(schedulemaster_update_params)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  def destroy
    Schedulemaster.destroy(params[:id])
    redirect_to action: :index
  end

  def queue_to_delayed_job
    if schedulemaster.calculation_status != 0
      redirect_to("/schedulemaster/#{schedulemaster.id}") && return
    end
    queue_name = "ScheduleGeneration_#{room.id}_#{schedulemaster.id}_#{Time.new.to_i}"
    schedulemaster.update!(
      calculation_status: 1,
      calculation_progress: 0,
      calculation_name: queue_name,
      calculation_begin: DateTime.now,
    )
    ScheduleGenerationJob.set(queue: queue_name).perform_later(
      schedulemaster.id,
      queue_name,
      'delayed_job',
    )
    redirect_to "/schedulemaster/#{schedulemaster.id}"
  end

  def queue_to_aws_batch
    if schedulemaster.calculation_status != 0
      redirect_to("/schedulemaster/#{schedulemaster.id}") && return
    end
    queue_name = "ScheduleGeneration_#{room.id}_#{schedulemaster.id}_#{Time.new.to_i}"
    schedulemaster.update!(
      calculation_status: 1,
      calculation_progress: 0,
      calculation_name: queue_name,
      calculation_begin: DateTime.now,
    )
    env1 = "SCHEDULEMASTER_ID=#{schedulemaster.id}"
    env2 = "QUEUE_NAME=#{queue_name}"
    exec = Rails.root.join('app', 'controllers', 'concerns', 'job_submit.sh')
    cmd = "#{env1} #{env2} source #{exec}"
    stdout, stderr, status = Open3.capture3(cmd)
    logger.info(stdout)
    logger.info(stderr)
    logger.info(status)
    redirect_to "/schedulemaster/#{schedulemaster.id}"
  end

  def overlook
    pdf = PdfOverlookSchedule.new(schedulemaster.id).render
    send_data pdf,
              filename: 'OverlookSchedule.pdf',
              type: 'application/pdf',
              disposition: 'inline'
  end

  private

  def schedulemaster_create_params
    params.require(:schedulemaster).permit(
      :room_id, :schedule_name, :schedule_type, :begindate, :enddate, :seatnumber, :totalclassnumber
    )
  end

  def schedulemaster_update_params
    params.require(:schedulemaster).permit(:max_count, :max_time_sec)
  end
end
