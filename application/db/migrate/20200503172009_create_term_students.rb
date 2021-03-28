class CreateTermStudents < ActiveRecord::Migration[5.2]
  def change
    create_table :term_students do |t|
      t.integer :term_id, null: false
      t.integer :student_id, null: false
      t.integer :school_grade, null: false
      t.integer :vacancy_status, null: false
      t.timestamps
    end
    add_index :term_students, [:term_id, :student_id], unique: true
    add_foreign_key :term_students, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :term_students, :students, on_update: :cascade, on_delete: :restrict
  end
end
