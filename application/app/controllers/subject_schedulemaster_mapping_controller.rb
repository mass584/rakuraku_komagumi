class SubjectSchedulemasterMappingController < ApplicationController
  include Mapping
  before_action :check_login
  before_action :check_schedulemaster
  helper_method :room
  helper_method :schedulemaster

  def new
    @subject_schedulemaster_mapping = SubjectSchedulemasterMapping.new
  end

  def create
    subject_id = params[:subject_schedulemaster_mapping][:subject_id]
    subject = Subject.find(subject_id)
    respond_to do |format|
      if associate_subject_to_schedulemaster(subject_id, @schedulemaster.id)
        Classnumber.bulk_create_each_subject(subject, @schedulemaster)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end
end
