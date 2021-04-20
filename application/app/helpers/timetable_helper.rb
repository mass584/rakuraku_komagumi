module TimetableHelper
  def begin_at_cell(begin_end_times, period_index)
    begin_end_time = begin_end_times.find do |item|
      item.period_index == period_index
    end
    time = I18n.l(begin_end_time.begin_at)
    content_tag(:td, class: 'align-middle bg-light') do
      content_tag(:div, 'data-id' => begin_end_time.id, 'data-begin_at' => time, 'class' => 'min-width-150') do
        time_field_tag(:begin_at, time, id: "begin_at_#{period_index}", class: 'form-control form-control-sm')
      end
    end
  end

  def end_at_cell(begin_end_times, period_index)
    begin_end_time = begin_end_times.find do |item|
      item.period_index == period_index
    end
    time = I18n.l(begin_end_time.end_at)
    content_tag(:td, class: 'align-middle bg-light') do
      content_tag(:div, 'data-id' => begin_end_time.id, 'data-end_at' => time, 'class' => 'min-width-150') do
        time_field_tag(:end_at, time, id: "end_at_#{period_index}", class: 'form-control form-control-sm')
      end
    end
  end

  def select_tag_status(timetable, term_groups)
    select = term_groups.reduce({ '開講' => 0, '休講' => -1 }) do |accu, term_group|
      accu.merge({ term_group.name => term_group.id })
    end
    selected = timetable.is_closed ? -1 : (timetable.term_group_id || 0)
    select_tag(
      :status,
      options_for_select(select, selected: selected),
      id: "select_status_#{timetable.id}",
      class: 'form-control form-control-sm',
    )
  end

  def timetable_table_cell(timetables, term_groups, date_index, period_index)
    timetable = timetables.find do |item|
      item.date_index == date_index && item.period_index == period_index
    end
    td_class = if timetable.is_closed
                 'align-middle bg-secondary'
               elsif timetable.term_group_id
                 'align-middle bg-warning-light'
               else
                 'align-middle'
               end
    content_tag(:td, class: td_class) do
      content_tag(:div,
                  'data-id' => timetable.id,
                  'data-is_closed' => timetable.is_closed,
                  'data-term_group_id' => timetable.term_group_id || 0,
                  'class' => 'min-width-150') do
        select_tag_status(timetable, term_groups)
      end
    end
  end
end
