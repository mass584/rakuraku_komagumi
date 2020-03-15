module TeacherrequestHelper
  def maru_batsu_button(teacherrequest, timetable, teacher)
    content_tag(:div,
                'data-id' => teacherrequest ? teacherrequest.id : nil,
                'data-teacher_id' => teacher.id,
                'data-timetable_id' => timetable.id) do
      button_tag(
        teacherrequest ? 'OK' : 'NG',
        class: teacherrequest ? 'btn btn-primary' : 'btn btn-danger',
        id: 'btn_maru_batsu'
      )
    end
  end
end