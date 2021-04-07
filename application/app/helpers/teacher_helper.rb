module TeacherHelper
  def teachers_table_content(teachers)
    {
      attributes: %w[氏名 メールアドレス 編集 削除],
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
        content_tag(:div) do
          render partial: 'teachers/edit', locals: { teacher: teacher }
        end,
        content_tag(:div) do
          render partial: 'teachers/destroy', locals: { teacher: teacher }
        end
      ],
    }
  end
end
