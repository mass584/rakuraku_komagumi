class StudentscheduleController < ApplicationController
  include RoomStore
  include SchedulemasterStore
  require './app/pdf/pdf_student_schedule'
  before_action :check_logined
  before_action :check_schedulemaster
  helper_method :room
  helper_method :schedulemaster

  def studentrequestmasters
    return @studentrequestmasters if defined? @studentrequestmasters

    @studentrequestmasters = Studentrequestmaster.get_studentrequestmasters(schedulemaster)
  end
  helper_method :studentrequestmasters

  def blank_schedule_counts
    return @blank_schedule_counts if defined? @blank_schedule_counts

    @blank_schedule_counts = {}
    @schedulemaster.ordered_students.each do |st|
      @blank_schedule_counts[st.id] =
        @schedulemaster.schedules.where(timetable_id: 0, student_id: st.id).count
    end
    @blank_schedule_counts
  end
  helper_method :blank_schedule_counts

  def index
    respond_to do |format|
      format.html do
        render 'studentschedule/index_list'
      end
      format.pdf do
        student_ids = params[:student_id].gsub(/[\"|\[|\]]/, '').split(',')
        pdf = PdfStudentSchedule.new(schedulemaster.id, student_ids).render
        send_data pdf,
                  filename: 'StudentSchedule.pdf',
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end
end
