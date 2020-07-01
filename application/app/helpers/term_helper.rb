module TermHelper
  def chart_data(term)
    {
      '未決定' => term.pieces.where(
        status: 0,
        timetable_id: nil,
      ).size,
      '仮決定' => term.pieces.where(
        status: 0,
      ).where.not(
        timetable_id: nil,
      ).size,
      '決定済' => term.pieces.where(
        status: 1,
      ).size,
    }
  end
end
