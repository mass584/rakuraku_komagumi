module SchedulemasterStore
  def schedulemaster
    return @schedulemaster if defined? @schedulemaster

    @schedulemaster = Schedulemaster.find(session[:schedulemaster_id])
  end
end
