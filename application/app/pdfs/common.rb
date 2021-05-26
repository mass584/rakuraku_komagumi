module Common
  COLOR_HEADER  = '343a40'.freeze
  COLOR_ENABLE  = 'fff0c6'.freeze
  COLOR_DISABLE = '6c757d'.freeze
  COLOR_BORDER  = 'dee2e6'.freeze
  COLOR_PLAIN = 'ffffff'.freeze

  def rotate?(term)
    term.max_period > 6 || term.one_week?
  end

  def header(term)
    begin_end_times = BeginEndTime.get_begin_end_times(term)
    theader = [
      {
        content: '日付',
        background_color: COLOR_HEADER,
      }
    ]
    tbody = term.period_array.map do |p|
      {
        content: "#{p}限\n#{begin_end_times[p].begin_at}〜#{begin_end_times[p].end_at}",
        background_color: COLOR_HEADER,
      }
    end
    theader + tbody
  end

  def header_left(date)
    {
      content: print_date(date),
      background_color: COLOR_HEADER,
    }
  end

  def print_piece_for_teacher(tutorial_piece)
    "[#{tutorial_piece.tutorial_contract.term_tutorial.tutorial.name}] #{tutorial_piece.tutorial_contract.term_student.student.name}"
  end

  def print_piece_for_student(piece)
    "[#{piece.contract.subject_term.subject.name}] #{piece.seat.term_teacher.teacher.name}"
  end
end
