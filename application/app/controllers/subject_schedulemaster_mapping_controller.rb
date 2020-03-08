class SubjectSchedulemasterMappingController < ApplicationController
  include Mapping
  before_action :check_login
  before_action :check_schedulemaster

  def create
    subject = Subject.find_by(id: create_params[:subject_id])
    respond_to do |format|
      if SubjectSchedulemasterMapping.additional_create(subject, @schedulemaster)
        format.js { @status = 'success' }
      else
        format.js { @status = 'fail' }
      end
    end
  end

  private

  def create_params
    params.require(:subject_schedulemaster_mapping).permit(:subject_id)
  end
end
