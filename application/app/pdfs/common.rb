module Common
  COLOR_HEADER  = '343a40'.freeze
  COLOR_ENABLE  = 'fff0c6'.freeze
  COLOR_DISABLE = '6c757d'.freeze
  COLOR_BORDER  = 'dee2e6'.freeze
  COLOR_PLAIN = 'ffffff'.freeze

  def rotate?(term)
    term.period_count > 6 || term.normal?
  end

  def header(term)
    theader = [
      {
        content: '日付',
        background_color: COLOR_HEADER,
      }
    ]
    tbody = term.period_index_array.map do |period_index|
      begin_at = I18n.l term.begin_end_times.find_by(period_index: period_index).begin_at
      end_at = I18n.l term.begin_end_times.find_by(period_index: period_index).end_at
      {
        content: "#{period_index}限\n#{begin_at}〜#{end_at}",
        background_color: COLOR_HEADER,
      }
    end
    theader + tbody
  end

  def header_left(term, date_index)
    {
      content: term.display_date(date_index),
    }
  end
end
