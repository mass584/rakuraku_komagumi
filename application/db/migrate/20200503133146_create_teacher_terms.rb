class CreateTeacherTerms < ActiveRecord::Migration[5.2]
  def change
    create_table :teacher_terms do |t|
      t.integer :teacher_id, null: false
      t.integer :term_id, null: false
      t.boolean :is_decided, default: false, null: false
      t.timestamps
    end
    add_index :teacher_terms, [:term_id, :teacher_id], unique: true
    add_foreign_key :teacher_terms, :terms, on_update: :cascade, on_delete: :cascade
    add_foreign_key :teacher_terms, :teachers, on_update: :cascade, on_delete: :restrict
  end
end
