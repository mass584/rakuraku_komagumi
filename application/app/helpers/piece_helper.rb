module PieceHelper
  def td_seat(term, timetable, seat)
    content_tag(:td) do
      div_seat(term, timetable, seat)
    end
  end

  def div_seat(term, timetable, seat)
    content_tag(:div,
                :class => %w[seat],
                :id => "seat_#{timetable.id}_#{seat}",
                'data-timetable_id' => timetable.id,
                'data-seat' => seat) do
      div_droppables(term, timetable, seat)
    end
  end

  def div_droppables(term, timetable, seat)
    term.pair_array.each do |pair|
      concat(
        content_tag(:div,
                    :class => %w[droppable],
                    :id => "droppable_#{timetable.id}_#{seat}_#{pair}",
                    'data-timetable_id' => timetable.id,
                    'data-students' => timetable.student_requests.map(&:student_id),
                    'data-teachers' => timetable.teacher_requests.map(&:teacher_id),
                    'data-seat' => seat,
                    'data-pair' => pair) do
                      div_draggable(find_piece(term, timetable, seat, pair))
                    end,
      )
    end
  end

  def div_draggable(piece)
    piece && content_tag(:div, "[#{piece.subject.name}]#{piece.student.name}",
                         :class => piece.fixed? ? %w[draggable fixed] : %(draggable),
                         :id => "draggable_#{piece.id}",
                         'data-piece_id' => piece.id,
                         'data-teacher_id' => piece.teacher_id,
                         'data-student_id' => piece.student_id,
                         'data-subject_id' => piece.subject_id)
  end

  def find_piece(term, timetable, seat, pair)
    pieces = term.all_pieces.dig(timetable.date, timetable.period) || []
    pieces_per_teacher = pieces.group_by(&:teacher_id)
    teacher_id = pieces_per_teacher.keys[seat - 1]
    pieces_for_teacher_id = pieces_per_teacher[teacher_id] || []
    pieces_for_teacher_id[pair - 1]
  end
end
