module TimetableHelper
  def get_select_class(status)
    case status
    when 0 then
      'selectbox-normal'
    when -1 then
      'selectbox-blank'
    end
  end
end
