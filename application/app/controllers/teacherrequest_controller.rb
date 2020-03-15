class TeacherrequestController < ApplicationController
  before_action :check_login
  before_action :check_schedulemaster
  before_action :check_schedulemaster_batch_status

  def index
    @teacherrequestmaster = Teacherrequestmaster.get_teacherrequestmasters(@schedulemaster)
    if params[:teacher_id].nil?
      @teachers = @schedulemaster.teachers.map { |teacher| { id: teacher.id } }
      render 'teacherrequest/index_teacher_list'
    elsif @teacherrequestmaster[params[:teacher_id].to_s].status == 0
      @timetables = Timetable.get_timetables(@schedulemaster)
      @teacher = Teacher.find(params[:teacher_id])
      @teacherrequests = Teacherrequest.get_teacherrequests(params[:teacher_id], @schedulemaster)
      render 'teacherrequest/index_status_not_ready'
    elsif @teacherrequestmaster[params[:teacher_id].to_s].status == 1
      @timetables = Timetable.get_timetables(@schedulemaster)
      @teacher = Teacher.find(params[:teacher_id])
      @teacherrequests = Teacherrequest.get_teacherrequests(params[:teacher_id], @schedulemaster)
      render 'teacherrequest/index_status_ready'
    end
  end

  def create
    record = Teacherrequest.new(create_params)
    if record.save
      render json: record, status: :ok
    else
      render json: record.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    record = Teacherrequest.find(params[:id])
    if record.destroy 
      render(json: {}, status: :no_content)
    else
      render(json: record.errors.full_messages, status: :bad_request)
    end
  end

  def update_master
    teacherrequestmaster = Teacherrequestmaster.find(params[:id])
    if teacherrequestmaster.update(status: params[:status])
      render json: {}, status: :no_content
    else
      render json: {}, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:teacherrequest).permit(
      :teacher_id,
      :timetable_id
    ).merge(
      schedulemaster_id: @schedulemaster.id
    )
  end
end
