module PieceHelper
  def div_seat(seat)
    content_tag(
      :div,
      :class => %w[seat],
      :id => "seat_#{seat.id}",
      'data-students' =>
        print_data_array(
          seat.timetable.student_requests.map(&:student_term_id),
        ),
      'data-teachers' =>
        print_data_array(
          seat.timetable.teacher_requests.map(&:teacher_term_id),
        ),
      'data-seat_id' => seat.id,
      'data-teacher_term_id' => seat.teacher_term_id,
      'data-date' => seat.timetable.date,
      'data-period' => seat.timetable.period,
    ) do
      concat(
        content_tag(
          :div,
          seat.teacher_term&.teacher&.name,
          class: %w[seat-teacher],
        ),
      )
      seat.term.frame_array.each do |frame|
        concat(
          content_tag(
            :div,
            :class => %w[frame],
            :id => "frame_#{seat.id}_#{frame}",
            'data-frame' => frame,
          ) do
            div_piece(seat, frame)
          end,
        )
      end
    end
  end

  def div_piece(seat, frame)
    piece = seat.pieces[frame - 1]
    piece && content_tag(
      :div,
      "#{piece.contract.student_term.student.name}
        #{piece.contract.subject_term.subject.name}",
      :class =>
        piece.is_fixed ?
        %w[piece piece__fixed] :
        %w[piece],
      :id => "piece_#{piece.id}",
      'data-piece_id' => piece.id,
      'data-teacher_term_id' => piece.contract.teacher_term_id,
      'data-teacher_name' => piece.contract.teacher_term&.teacher&.name,
      'data-subject_term_id' => piece.contract.subject_term_id,
      'data-subject_name' => piece.contract.subject_term&.subject&.name,
      'data-student_term_id' => piece.contract.student_term_id,
      'data-student_name' => piece.contract.student_term&.student&.name,
      'data-src_seat_id' => nil,
    )
  end

  def select_student_term_id(term)
    select_tag(
      :student_term_id,
      options_for_select(term.student_terms.reduce({}) do |accu, item|
        accu.merge({ item.student.name => item.id })
      end),
      include_blank: '生徒を選択',
      id: 'select_student_term_id',
      class: 'form-control',
      onchange: 'cb_select_student_term_id(event);',
    )
  end

  def select_subject_term_id(term)
    select_tag(
      :subject_term_id,
      options_for_select(term.subject_terms.reduce({}) do |accu, item|
        accu.merge({ item.subject.name => item.id })
      end),
      include_blank: '科目を選択',
      id: 'select_subject_term_id',
      class: 'form-control',
      onchange: 'cb_select_subject_term_id(event);',
    )
  end
end
