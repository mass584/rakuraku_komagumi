module WeekHelper
  def display_week(week)
    "第#{week}週"
  end

  def div_week_selector(term, week)
    content_tag(:div, class: 'row mt-4 justify-content-md-center align-items-center') do
      concat(
        button_to(
          '<< 最初の週',
          { controller: :timetable, action: :index },
          {
            method: :get,
            class: 'btn btn-sm btn-dark m-1',
            params: { week: term.min_week },
            disabled: week <= term.min_week,
          },
        ),
      )
      concat(
        button_to(
          '< 前の週',
          { controller: :timetable, action: :index },
          {
            method: :get,
            class: 'btn btn-sm btn-dark m-1',
            params: { week: week - 1 },
            disabled: week <= term.min_week,
          },
        ),
      )
      concat(
        content_tag(:div, "#{display_week(week)}", { class: 'm-0 col-lg-2 text-center h3' }),
      )
      concat(
        button_to(
          '次の週 >',
          { controller: :timetable, action: :index },
          {
            method: :get,
            class: 'btn btn-sm btn-dark m-1',
            params: { week: week + 1 },
            disabled: week >= term.max_week,
          },
        ),
      )
      concat(
        button_to(
          '最後の週 >>',
          { controller: :timetable, action: :index },
          {
            method: :get,
            class: 'btn btn-sm btn-dark m-1',
            params: { week: term.max_week },
            disabled: week >= term.max_week,
          },
        ),
      )
    end
  end
end
