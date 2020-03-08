module SchedulemasterHelper
  def chart_data(schedulemaster)
    {
      '未決定' => schedulemaster.schedules.where(
        status: 0,
        timetable_id: nil,
      ).size,
      '仮決定' => schedulemaster.schedules.where(
        status: 0,
      ).where.not(
        timetable_id: nil,
      ).size,
      '決定済' => schedulemaster.schedules.where(
        status: 1,
      ).count,
    }
  end
end
