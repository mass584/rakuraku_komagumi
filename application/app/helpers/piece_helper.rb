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
                :class => %w[droppable],
                :id => "frame_#{timetable.id}_#{seat}_#{frame}",
                'data-frame' => frame) do
                  div_piece(term, timetable, seat, frame)
                end
  end

  def div_piece(term, timetable, seat, frame)
    piece = find_piece(term, timetable, seat, frame)
    piece && content_tag(:div,
                         "[#{piece.subject.name}]#{piece.student.name}",
                         :class => piece.fixed? ? %w[draggable fixed] : %w[draggable],
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
end
