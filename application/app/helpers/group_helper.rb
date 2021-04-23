module GroupHelper
  def groups_table_content(groups)
    {
      attributes: %w[科目名 科目短縮名 表示順 編集 削除],
      records: groups.map do |group|
        group_table_record(group)
      end,
    }
  end

  def group_table_record(group)
    {
      id: group.id,
      tds: [
        group.name,
        group.short_name,
        group.order,
        content_tag(:div) do
          render partial: 'groups/edit', locals: { group: group }
        end,
        content_tag(:div) do
          render partial: 'groups/destroy', locals: { group: group }
        end
      ],
    }
  end
end
