module TermStudentHelper
  def options_for_select_student_id(room, term)
    plucked_students = room.students.active.pluck(:name, :id) 
    plucked_term_students = term.term_students.ordered.joins(:student).pluck( 'students.name', :student_id)
    plucked_students - plucked_term_students
  end

  def student_request_button(student_request, timetable, student_term)
    content_tag(:div,
                'data-id' => student_request ? student_request.id : nil,
                'data-student_term_id' => student_term.id,
                'data-timetable_id' => timetable.id) do
      button_tag(
        student_request ? 'OK' : 'NG',
        class: student_request ? 'btn btn-primary' : 'btn btn-danger',
        id: "btn_#{timetable.id}",
        disabled: student_term.is_decided,
      )
    end
  end

  def schedule_cell(pieces)
    content_tag(:div) do
      pieces.each do |piece|
        concat(
          content_tag(:div) do
            "#{piece.contract.subject_term.subject.name}
            （#{piece.seat.teacher_term.teacher.name}）"
          end,
        )
      end
    end
  end
end
