class CreateTermTeachers < ActiveRecord::Migration[5.2]
  def change
    create_table :term_teachers do |t|
      t.integer :term_id, null: false
      t.integer :teacher_id, null: false
      t.integer :vacancy_status, null: false
      t.timestamps
    end
    add_index :term_teachers, [:term_id, :teacher_id], unique: true
    add_foreign_key :term_teachers, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :term_teachers, :teachers, on_update: :cascade, on_delete: :restrict
  end
end
