class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true


  private

  def self.daily_occupations_from(tutorials_and_groups)
    tutorials_and_groups.values.reduce(0) do |accu, item|
      item.length.positive? ? accu + 1 : accu
    end
  end

  def self.daily_blanks_from(tutorials_and_groups)
    init = { flag: false, buffer: 0, sum: 0 }
    result = tutorials_and_groups.values.reduce(init) do |accu, item|
      {
        flag: accu[:flag] || item.length.positive?,
        buffer: item.length.zero? ? accu[:buffer] + 1 : 0,
        sum: (accu[:flag] && item.length.positive?) ? accu[:sum] + accu[:buffer] : accu[:sum],
      }
    end
    result[:sum]
  end
end
