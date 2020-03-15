module TimetableHelper
  def get_select_class(status)
    case status
    when 0 then
      ''
    when -1 then
      'bg-inactive'
    end
  end
end
