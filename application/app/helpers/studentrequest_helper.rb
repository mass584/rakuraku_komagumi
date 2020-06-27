module StudentrequestHelper
  def maru_batsu_button(studentrequest, timetable, student)
    content_tag(:div,
                'data-id' => studentrequest ? studentrequest.id : nil,
                'data-student_id' => student.id,
                'data-timetable_id' => timetable.id) do
      button_tag(
        studentrequest ? 'OK' : 'NG',
        class: studentrequest ? 'btn btn-primary' : 'btn btn-danger',
        id: 'btn_maru_batsu'
      )
    end
  end
end