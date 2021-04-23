module OccupationsBlanks
  def daily_occupations_from(term, tutorials, groups)
    merge_tutorials_and_groups(term, tutorials,
                               groups).sort.to_h.values.reduce(0) do |accu, occupied|
      occupied ? accu + 1 : accu
    end
  end

  def daily_blanks_from(term, tutorials, groups)
    init = { flag: false, buffer: 0, sum: 0 }
    result = merge_tutorials_and_groups(term, tutorials,
                                        groups).sort.to_h.values.reduce(init) do |accu, occupied|
      {
        flag: accu[:flag] || occupied,
        buffer: occupied ? 0 : accu[:buffer] + 1,
        sum: accu[:flag] && occupied ? accu[:sum] + accu[:buffer] : accu[:sum],
      }
    end
    result[:sum]
  end

  private

  def merge_tutorials_and_groups(term, term_tutorials_group_by_period, term_groups_group_by_period)
    term.period_index_array.reduce({}) do |accu, period_index|
      tutorial_exist = term_tutorials_group_by_period[period_index].to_a.count.positive?
      group_exist = term_groups_group_by_period[period_index].to_a.count.positive?
      accu.merge({ period_index => tutorial_exist || group_exist })
    end
  end
end
