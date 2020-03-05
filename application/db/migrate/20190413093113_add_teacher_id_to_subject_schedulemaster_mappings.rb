class AddTeacherIdToSubjectSchedulemasterMappings < ActiveRecord::Migration[5.2]
  def change
    add_column :subject_schedulemaster_mappings, :teacher_id, :integer, default: 0, null: false
  end
end
