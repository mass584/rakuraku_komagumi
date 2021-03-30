class GroupContract < ApplicationRecord
  belongs_to :term
  belongs_to :term_student
  belongs_to :term_group

  validates :is_contracted,
            exclusion: { in: [nil], message: 'にnilは許容されません' }

  validate :can_update_is_contracted,
            on: :update,
            if: :will_save_change_to_is_contracted?

  def self.new(attributes = {})
    attributes[:is_contracted] ||= false
    super(attributes)
  end

  def self.group_by_date_and_period
    term.timetables.reduce({}) do |accu, timetable|
      accu.deep_merge({
        timetable.date_index => {
          timetable.period_index => itself.group_contracts(timetable),
        }
      })
    end
  end

  def self.group_contracts(timetable)
    itself.select do |group_contract|
      group_contract.term_group_id == timetable.term_group_id && group_contract.is_contracted
    end
  end

  private

  def can_update_is_contracted
    # 追加時、生徒に空きコマ数違反が起こらない
    # 追加時、生徒に合計コマ数違反が起こらない
    # 削除時、生徒に空きコマ数違反が起こらない
  end
end
