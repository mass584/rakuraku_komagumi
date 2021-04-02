class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true


  private

  def self.merge_tutorials_and_groups(term, term_tutorials_group_by_period, term_groups_group_by_period)
    term.period_index_array.reduce({}) do |accu, period_index|
      tutorial_exist = term_tutorials_group_by_period.dig(period_index).to_a.count.positive?
      group_exist = term_groups_group_by_period.dig(period_index).to_a.count.positive?
      accu.merge({ period_index => tutorial_exist || group_exist })
    end
  end

  def self.daily_occupations_from(tutorials_and_groups)
    tutorials_and_groups.sort.to_h.values.reduce(0) do |accu, occupied|
      occupied ? accu + 1 : accu
    end
  end

  def self.daily_blanks_from(tutorials_and_groups)
    init = { flag: false, buffer: 0, sum: 0 }
    result = tutorials_and_groups.sort.to_h.values.reduce(init) do |accu, occupied|
      {
        flag: accu[:flag] || occupied,
        buffer: !occupied ? accu[:buffer] + 1 : 0,
        sum: (accu[:flag] && occupied) ? accu[:sum] + accu[:buffer] : accu[:sum],
      }
    end
    result[:sum]
  end
end
