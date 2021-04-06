module GroupHelper
  def groups_table_content(groups)
    {
      attributes: %w[科目名 種別 表示順 編集 削除],
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
        group.model_name.human,
        content_tag(:div, id: "order_#{group.id}") do
          "#{group.order}"
        end,
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
