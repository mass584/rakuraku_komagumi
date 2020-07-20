module TermHelper
  def chart_data(term)
    {
      '未決定' => term.pieces.where(
        is_fixed: false,
        seat_id: nil,
      ).size,
      '仮決定' => term.pieces.where(
        is_fixed: false,
      ).where.not(
        seat_id: nil,
      ).size,
      '決定済' => term.pieces.where(
        is_fixed: true,
      ).size,
    }
  end
end
