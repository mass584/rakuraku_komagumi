module TeacherHelper
  def teacher_subject_button(teacher_subject, teacher, subject)
    content_tag(:div,
                'data-id' => teacher_subject ? teacher_subject.id : nil,
                'data-teacher_id' => teacher.id,
                'data-subject_id' => subject.id) do
      button_tag(
        teacher_subject ? '可' : '不',
        id: "button_#{teacher.id}_#{subject.id}",
        class: teacher_subject ? 'btn btn-primary' : 'btn btn-danger',
      )
    end
  end
end
