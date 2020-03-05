class CreateSubjectSchedulemasterMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :subject_schedulemaster_mappings do |t|
      t.integer :subject_id, null: false
      t.integer :schedulemaster_id, null: false
      t.timestamps
    end
    add_index :subject_schedulemaster_mappings,
              [:schedulemaster_id, :subject_id],
              name: 'index_subject_schedulemaster_mapping',
              unique: true
    add_foreign_key :subject_schedulemaster_mappings, :schedulemasters, on_update: :cascade, on_delete: :cascade
    add_foreign_key :subject_schedulemaster_mappings, :subjects, on_update: :cascade, on_delete: :restrict
  end
end
