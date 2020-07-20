module ApplicationHelper
  def youbi(number)
    %w[日 月 火 水 木 金 土][number]
  end

  def error_msg(messages)
    content_tag :ul do
      messages.each do |item|
        concat content_tag(:li, item)
      end
    end
  end

  def print_week(week)
    "第#{week}週"
  end

  def print_period(period)
    "#{period}限"
  end

  def print_seat(seat)
    "#{seat}番"
  end

  def print_date(date, type)
    case type
    when 'one_week'
      youbi(date.wday)
    when 'variable'
      "#{date} #{youbi(date.wday)}"
    end
  end

  def print_piece_for_teacher(piece)
    "#{piece.student.grade_when(piece.term)} #{piece.student.name} [#{piece.subject.name}]"
  end

  def print_piece_for_student(piece)
    "[#{piece.subject.name}] #{piece.teacher.name}"
  end

  def print_data_array(array)
    str = array.map { |item| "\"#{item}\"" }.join(', ')
    '[' + str + ']'
  end
end
