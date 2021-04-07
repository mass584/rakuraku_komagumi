module ApplicationHelper
  def enum_to_select(model, enum_attr)
    model.send(enum_attr.pluralize).map do |key, _value|
      [model.send("#{enum_attr.pluralize}_i18n")[key], key]
    end
  end

  def print_period(period)
    "#{period}限"
  end

  def print_seat(seat)
    "#{seat}番"
  end

  def error_msg(messages)
    content_tag :ul do
      messages.each do |item|
        concat content_tag(:li, item)
      end
    end
  end
end
