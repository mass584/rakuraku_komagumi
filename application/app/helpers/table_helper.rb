module TableHelper
  def subject_table_content(subjects)
    {
      attributes: %w[科目名 表示順 編集 削除],
      records: subjects.map do |subject|
        subject_table_record(subject)
      end,
    }
  end

  def subject_table_record(subject)
    {
      id: subject.id,
      tds: [
        subject.name,
        subject.order,
        content_tag(:div) do
          render partial: 'subject/edit', locals: { subject: subject }
        end,
        content_tag(:div) do
          concat render partial: 'subject/destroy', locals: { subject: subject }
        end
      ],
    }
  end
end
