module StudentscheduleHelper
  def td_studentrequest_status(student_id)
    case studentrequestmasters[student_id].status
    when 0 then
      content_tag(:td, '未完了', 'class' => %w[print alert])
    when 1 then
      content_tag(:td, '完了', 'class' => ['print'])
    end
  end

  def td_blank_studentschedule_count(student_id)
    count = blank_schedule_counts[student_id]
    case count
    when 0 then
      content_tag(:td, count, 'class' => ['print'])
    else
      content_tag(:td, count, 'class' => %w[print alert])
    end
  end
end
