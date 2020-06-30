class BeginEndTime < ApplicationRecord
  belongs_to :term

  def self.get_begin_end_times(term)
    term.period_array.reduce({}) do |accu, period|
      accu.merge({
        period.to_s => find_by(
          term_id: term.id,
          period: period,
        ),
      })
    end
  end

  def self.bulk_create(term)
    term.period_array.each do |period|
      BeginEndTime.create(
        term_id: term.id,
        period: period,
        begin_at: '18:00',
        end_at: '18:00',
      )
    end
  end
end
