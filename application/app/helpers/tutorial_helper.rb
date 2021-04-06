module TutorialHelper
  def tutorials_table_content(tutorials)
    {
      attributes: %w[科目名 種別 表示順 編集 削除],
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
        tutorial.model_name.human,
        content_tag(:div, id: "order_#{tutorial.id}") do
          "#{tutorial.order}"
        end,
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
