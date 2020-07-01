class StudentscheduleController < ApplicationController
  before_action :check_logined
  before_action :check_schedulemaster

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
end
