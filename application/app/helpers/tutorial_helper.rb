module TutorialHelper
  def tutorials_table_content(tutorials)
    {
      attributes: %w[科目名 科目短縮名 表示順 編集 削除],
      records: tutorials.map do |tutorial|
        tutorial_table_record(tutorial)
      end,
    }
  end

  def tutorial_table_record(tutorial)
    {
      id: tutorial.id,
      tds: [
        tutorial.name,
        tutorial.short_name,
        tutorial.order,
        content_tag(:div) do
          render partial: 'tutorials/edit', locals: { tutorial: tutorial }
        end,
        content_tag(:div) do
          render partial: 'tutorials/destroy', locals: { tutorial: tutorial }
        end
      ],
    }
  end
end
