class RemoveColumnStudentSchedulemasterMappings < ActiveRecord::Migration[5.2]
  def up
    remove_column :student_schedulemaster_mappings, :grade
  end

  def down
    add_column :student_schedulemaster_mappings, :grade, :integer, after: :schedulemaster_id
    change_column :student_schedulemaster_mappings, :grade, :integer, null: false
  end
end
