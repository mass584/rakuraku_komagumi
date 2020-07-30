module StudentHelper
  def student_subject_button(student_subject, student, subject)
    content_tag(:div,
                'data-id' => student_subject ? student_subject.id : nil,
                'data-student_id' => student.id,
                'data-subject_id' => subject.id) do
      button_tag(
        student_subject ? '受' : '未',
        id: "button_#{student.id}_#{subject.id}",
        class: student_subject ? 'btn btn-primary' : 'btn btn-danger',
      )
    end
  end
end
