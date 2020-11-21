module TableHelper
  def teacher_table_content(teachers)
    {
      attributes: %w[氏名 メールアドレス 電話番号 編集 削除],
      records: teachers.map do |teacher|
        teacher_table_record(teacher)
      end,
    }
  end

  def teacher_table_record(teacher)
    {
      id: teacher.id,
      tds: [
        teacher.name,
        teacher.email,
        teacher.tel,
        content_tag(:div) do
          render partial: 'teacher/edit', locals: { teacher: teacher }
        end,
        content_tag(:div) do
          concat render partial: 'teacher/destroy', locals: { teacher: teacher }
        end
      ],
    }
  end
end
