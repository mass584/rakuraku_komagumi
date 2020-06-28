class CreateStudentTerms < ActiveRecord::Migration[5.2]
  def change
    create_table :student_terms do |t|
      t.integer :student_id, null: false
      t.integer :term_id, null: false
      t.integer :status, null: false
      t.timestamps
    end
    add_index :student_terms, [:term_id, :student_id], unique: true
    add_foreign_key :student_terms, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :student_terms, :students, on_update: :cascade, on_delete: :restrict
  end
end
