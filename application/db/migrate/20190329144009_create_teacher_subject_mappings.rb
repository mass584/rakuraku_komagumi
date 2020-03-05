class CreateTeacherSubjectMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :teacher_subject_mappings do |t|
      t.integer :subject_id, null: false
      t.integer :teacher_id, null: false
      t.timestamps
    end
    add_foreign_key :teacher_subject_mappings, :subjects, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacher_subject_mappings, :teachers, on_update: :cascade, on_delete: :cascade
    add_index :teacher_subject_mappings, [:subject_id, :teacher_id], unique: true
  end
end
