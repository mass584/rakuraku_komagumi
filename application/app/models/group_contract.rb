class GroupContract < ApplicationRecord
  belongs_to :term
  belongs_to :term_student
  belongs_to :term_group

  validates :is_contracted,
            exclusion: { in: [nil], message: 'にnilは許容されません' }

  validate :can_update_is_contracted,
            on: :update,
            if: :will_save_change_to_is_contracted?

  def self.new(attr = {})
    attr[:is_contracted] || = false
    super(attr)
  end

  private

  def can_update_is_contracted
    # 追加時、生徒に空きコマ数違反が起こらない
    # 追加時、生徒に合計コマ数違反が起こらない
    # 削除時、生徒に空きコマ数違反が起こらない
  end
end
