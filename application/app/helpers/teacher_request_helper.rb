module TeacherRequestHelper
  def maru_batsu_button(teacher_request, timetable, teacher)
    content_tag(:div,
                'data-id' => teacher_request ? teacher_request.id : nil,
                'data-teacher_id' => teacher.id,
                'data-timetable_id' => timetable.id) do
      button_tag(
        teacher_request ? 'OK' : 'NG',
        class: teacher_request ? 'btn btn-primary' : 'btn btn-danger',
        id: 'btn_maru_batsu'
      )
    end
  end
end