class CreateTeacherSchedulemasterMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :teacher_schedulemaster_mappings do |t|
      t.integer :teacher_id, null: false
      t.integer :schedulemaster_id, null: false
      t.timestamps
    end
    add_index :teacher_schedulemaster_mappings,
              [:schedulemaster_id, :teacher_id],
              name: 'index_teacher_schedulemaster_mapping',
              unique: true
    add_foreign_key :teacher_schedulemaster_mappings, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacher_schedulemaster_mappings, :teachers, on_update: :cascade, on_delete: :restrict
  end
end
