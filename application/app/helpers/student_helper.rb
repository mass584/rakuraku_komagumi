module StudentHelper
  def students_table_content(students)
    {
      attributes: %w[氏名 学年 メールアドレス 編集 削除],
      records: students.map do |student|
        student_table_record(student)
      end,
    }
  end

  def student_table_record(student)
    {
      id: student.id,
      tds: [
        student.name,
        student.school_grade_i18n,
        student.email,
        content_tag(:div) do
          render partial: 'students/edit', locals: { student: student }
        end,
        content_tag(:div) do
          render partial: 'students/destroy', locals: { student: student }
        end
      ],
    }
  end
end
