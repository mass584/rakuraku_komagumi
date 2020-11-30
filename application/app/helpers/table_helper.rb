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

  def student_table_content(students)
    {
      attributes: %w[氏名 学年 メールアドレス 電話番号 編集 削除],
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
        student.school_grade,
        student.email,
        student.tel,
        content_tag(:div) do
          render partial: 'student/edit', locals: { student: student }
        end,
        content_tag(:div) do
          concat render partial: 'student/destroy', locals: { student: student }
        end
      ],
    }
  end

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
