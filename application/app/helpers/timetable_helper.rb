module TimetableHelper
  def td_class(status)
    case status
    when 'opened'
      ''
    when 'closed'
      'bg-inactive'
    end
  end
end
