class CreateTeacherSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :teacher_subjects do |t|
      t.integer :teacher_id, null: false
      t.integer :subject_id, null: false
      t.timestamps
    end
    add_index :teacher_subjects, [:teacher_id, :subject_id], unique: true
    add_foreign_key :teacher_subjects, :teachers, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacher_subjects, :subjects, on_update: :cascade, on_delete: :cascade
  end
end
