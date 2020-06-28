class CreateStudentSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :student_subjects do |t|
      t.integer :student_id, null: false
      t.integer :subject_id, null: false
      t.timestamps
    end
    add_index :student_subjects, [:student_id, :subject_id], unique: true
    add_foreign_key :student_subjects, :students, on_update: :cascade, on_delete: :cascade
    add_foreign_key :student_subjects, :subjects, on_update: :cascade, on_delete: :cascade
  end
end
