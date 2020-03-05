class CreateStudentSubjectMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :student_subject_mappings do |t|
      t.integer :student_id, null: false
      t.integer :subject_id, null: false
      t.timestamps
    end
    add_index :student_subject_mappings,
              [:student_id, :subject_id],
              name: 'index_student_subject_mapping',
              unique: true
    add_foreign_key :student_subject_mappings, :subjects, on_update: :cascade, on_delete: :cascade
    add_foreign_key :student_subject_mappings, :students, on_update: :cascade, on_delete: :cascade
  end
end
