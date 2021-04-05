module ApplicationHelper
  def enum_to_select(model, enum_attr)
    model.send(enum_attr.pluralize).map do |key, _value|
      [model.send("#{enum_attr.pluralize}_i18n")[key], key]
    end
  end

  def youbi(number)
    %w[日 月 火 水 木 金 土][number]
  end

  def print_date(date)
    "#{date.strftime('%Y/%m/%d')}（#{youbi(date.wday)}）"
  end

  def print_period(period)
    "#{period}限"
  end

  def print_seat(seat)
    "#{seat}番"
  end

  def print_data_array(array)
    str = array.map { |item| "\"#{item}\"" }.join(', ')
    '[' + str + ']'
  end

  def error_msg(messages)
    content_tag :ul do
      messages.each do |item|
        concat content_tag(:li, item)
      end
    end
  end
end
