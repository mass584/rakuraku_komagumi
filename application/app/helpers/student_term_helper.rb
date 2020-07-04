module StudentTermHelper
  def student_request_button(student_request, timetable, student_term)
    content_tag(:div,
                'data-id' => student_request ? student_request.id : nil,
                'data-student_id' => student_term.student_id,
                'data-timetable_id' => timetable.id) do
      button_tag(
        student_request ? 'OK' : 'NG',
        class: student_request ? 'btn btn-primary' : 'btn btn-danger',
        id: "btn_#{timetable.id}",
        disabled: student_term.ready?,
        onclick: student_term.ready? ? '' : 'cb_button(event)',
      )
    end
  end
end
