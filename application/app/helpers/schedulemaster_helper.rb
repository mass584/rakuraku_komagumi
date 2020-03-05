module SchedulemasterHelper
  def button_calculation_rule(eval_target)
    case eval_target
    when 'teacher' then
      name = '講師設定'
      rule = schedulemaster.calculation_rules.find_by(eval_target: 'teacher')
    when 'student' then
      name = '生徒設定'
      rule = schedulemaster.calculation_rules.find_by(eval_target: 'student')
    when 'student3g' then
      name = '中３生徒設定'
      rule = schedulemaster.calculation_rules.find_by(eval_target: 'student3g')
    end
    button_to name,
              edit_calculation_rule_path(rule),
              class: 'btn btn-sm btn-default', method: :get, remote: true
  end

  def calculation_result(schedulemaster)
    if schedulemaster.calculation_end
      end_time = schedulemaster.calculation_end.in_time_zone('Tokyo').strftime('%Y年%m月%d日 %H:%M:%S')
      result = schedulemaster.calculation_result
      "前回の計算終了日時は #{end_time} です。\n#{result}"
    else
      "計算はまだ実行されていません。\n"
    end
  end

  def chart_data(schedulemaster)
    schedules_blank =
      schedulemaster.schedules.joins(:subject).where(
        'subjects.classtype': '個別授業',
        status: 0,
        timetable_id: 0,
      ).count
    schedules_temporary =
      schedulemaster.schedules.joins(:subject).where(
        'subjects.classtype': '個別授業',
        status: 0,
      ).where.not(
        timetable_id: 0,
      ).count
    schedules_fixed =
      schedulemaster.schedules.joins(:subject).where(
        'subjects.classtype': '個別授業',
        status: 1,
      ).count
    {
      '未決定' => schedules_blank,
      '仮決定' => schedules_temporary,
      '決定済' => schedules_fixed,
    }
  end
end
