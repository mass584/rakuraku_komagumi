module TeacherscheduleHelper
  def td_teacherrequest_status(teacher_id)
    case teacherrequestmasters[teacher_id].status
    when 0 then
      content_tag(:td, '未完了', 'class' => %w[print alert])
    when 1 then
      content_tag(:td, '完了', 'class' => ['print'])
    end
  end

  def td_blank_teacherschedule_counts(teacher_id)
    count = blank_schedule_counts[teacher_id]
    case count
    when 0 then
      content_tag(:td, count, 'class' => ['print'])
    else
      content_tag(:td, count, 'class' => %w[print alert])
    end
  end
end
