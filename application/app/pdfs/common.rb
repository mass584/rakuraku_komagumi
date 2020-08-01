module Common
  include ApplicationHelper
  COLOR_HEADER  = 'fdf5e6'.freeze
  COLOR_DISABLE = '7f7f7f'.freeze
  COLOR_ENABLE  = 'ffffff'.freeze
  COLOR_BORDER  = 'ffffff'.freeze

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

  def print_piece_for_teacher(piece)
    "[#{piece.contract.subject_term.subject.name}] #{piece.contract.student_term.student.name}"
  end

  def print_piece_for_student(piece)
    "[#{piece.contract.subject_term.subject.name}] #{piece.seat.teacher_term.teacher.name}"
  end
end
