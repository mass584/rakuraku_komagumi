class StudentrequestController < ApplicationController
  before_action :check_login
  before_action :check_schedulemaster
  before_action :check_schedulemaster_batch_status

  def index
    @studentrequestmaster = Studentrequestmaster.get_studentrequestmasters(@schedulemaster)
    if params[:student_id].nil?
      @students = @schedulemaster.students.map { |student| { id: student.id } }
      render 'studentrequest/index_student_list'
    elsif @studentrequestmaster[params[:student_id].to_s].status == 0
      @timetables = Timetable.get_timetables(@schedulemaster)
      @student = Student.find(params[:student_id])
      @studentrequests = Studentrequest.get_studentrequests(params[:student_id], @schedulemaster)
      render 'studentrequest/index_status_not_ready'
    elsif @studentrequestmaster[params[:student_id].to_s].status == 1
      @timetables = Timetable.get_timetables(@schedulemaster)
      @student = Student.find(params[:student_id])
      @studentrequests = Studentrequest.get_studentrequests(params[:student_id], @schedulemaster)
      render 'studentrequest/index_status_ready'
    end
  end

  def create
    record = Studentrequest.new(create_params)
    if record.save
      render json: record, status: :ok
    else
      render json: record.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    record = Studentrequest.find(params[:id])
    if record.destroy 
      render(json: {}, status: :no_content)
    else
      render(json: record.errors.full_messages, status: :bad_request)
    end
  end

  def update_master
    studentrequestmaster = Studentrequestmaster.find(params[:id])
    if studentrequestmaster.update(status: params[:status])
      render json: {}, status: :no_content
    else
      render json: {}, status: :bad_request
    end
  end

  private

  def create_params
    params.require(:studentrequest).permit(
      :student_id,
      :timetable_id
    ).merge(
      schedulemaster_id: @schedulemaster.id
    )
  end
end
