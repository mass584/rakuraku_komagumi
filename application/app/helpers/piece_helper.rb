module PieceHelper
  def div_seat(term, timetable, seat)
    content_tag(:div,
                :class => %w[seat],
                :id => "seat_#{timetable.id}_#{seat}",
                'data-timetable_id' => timetable.id,
                'data-students' =>
                  print_data_array(timetable.student_requests.map(&:student_id)),
                'data-teachers' =>
                  print_data_array(timetable.teacher_requests.map(&:teacher_id)),
                'data-seat' => seat) do
                  term.frame_array.each do |frame|
                    concat(div_frame(term, timetable, seat, frame))
                  end
                end
  end

  def div_frame(term, timetable, seat, frame)
    content_tag(:div,
                :class => %w[frame],
                :id => "frame_#{timetable.id}_#{seat}_#{frame}",
                'data-frame' => frame) do
                  div_piece(term, timetable, seat, frame)
                end
  end

  def div_piece(term, timetable, seat, frame)
    piece = find_piece(term, timetable, seat, frame)
    piece && content_tag(:div,
                         "#{piece.student.name} #{piece.subject.name}",
                         :class =>
                           piece.fixed? ?
                           %w[piece piece__fixed] :
                           %w[piece],
                         :id => "piece_#{piece.id}",
                         'data-piece_id' => piece.id,
                         'data-teacher_id' => piece.teacher_id,
                         'data-student_id' => piece.student_id,
                         'data-subject_id' => piece.subject_id)
  end

  def find_piece(term, timetable, seat, frame)
    pieces = term.all_pieces.dig(timetable.date, timetable.period) || []
    pieces_per_teacher = pieces.group_by(&:teacher_id)
    teacher_id = pieces_per_teacher.keys[seat - 1]
    pieces_for_teacher_id = pieces_per_teacher[teacher_id] || []
    pieces_for_teacher_id[frame - 1]
  end

  def select_student_id(term)
    options = content_tag(:option, '選択してください', 'value' => '') +
              options_from_collection_for_select(term.students, :id, :name)
    content_tag(:div, class: 'form-group') do
      concat(label_tag('select_student_id', '生徒の選択'))
      concat(select_tag(
               :student_id,
               options,
               id: 'select_student_id',
               class: 'form-control',
               onchange: 'cb_select_student_id(event);',
             ))
    end
  end

  def select_subject_id(term)
    options = content_tag(:option, '選択してください', 'value' => '') +
              options_from_collection_for_select(term.subjects, :id, :name)
    content_tag(:div, class: 'form-group') do
      concat(label_tag('select_subject_id', '科目の選択'))
      concat(select_tag(
               :subject_id,
               options,
               id: 'select_subject_id',
               class: 'form-control',
               onchange: 'cb_select_subject_id(event);',
             ))
    end
  end

  def div_open_button
    content_tag(:div,
                '●',
                class: %w[open-button],
                id: 'open-button',
                onclick: 'cb_open_button(event);')
  end

  def div_holding
    content_tag(:div, '', class: %w[holding], id: 'holding')
  end
end
