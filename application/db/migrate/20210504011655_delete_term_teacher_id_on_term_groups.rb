class DeleteTermTeacherIdOnTermGroups < ActiveRecord::Migration[6.1]
  def change
    remove_column :term_groups, :term_teacher_id
  end
end
