module StudentRequestHelper
  def maru_batsu_button(student_request, timetable, student)
    content_tag(:div,
                'data-id' => student_request ? student_request.id : nil,
                'data-student_id' => student.id,
                'data-timetable_id' => timetable.id) do
      button_tag(
        student_request ? 'OK' : 'NG',
        class: student_request ? 'btn btn-primary' : 'btn btn-danger',
        id: 'btn_maru_batsu'
      )
    end
  end
end