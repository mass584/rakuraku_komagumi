module Common
  COLOR_HEADER  = 'fdf5e6'.freeze
  COLOR_DISABLE = '7f7f7f'.freeze
  COLOR_ENABLE  = 'ffffff'.freeze
  COLOR_BORDER  = 'ffffff'.freeze

  def rotate?(term)
    term.max_period > 6 || term.one_week?
  end

  def header(term)
    begin_end_times = BeginEndTime.get_begin_end_times(term)
    theader = [
      {
        content: '日付',
        background_color: COLOR_HEADER,
      }
    ]
    tbody = term.period_array.map do |p|
      {
        content: "#{p}限\n#{begin_end_times[p].begin_at}〜#{begin_end_times[p].end_at}",
        background_color: COLOR_HEADER,
      }
    end
    theader + tbody
  end
end
